note
	description: "Summary description for {XMPP_PROTOCOL}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_PROTOCOL

inherit
	XMPP_STREAM
		rename
			make as make_stream
		end

create
	make,
	make_with_parameters

feature {NONE} -- Initialization

	make_with_parameters (p: XMPP_PARAMETERS)
			-- Create connection with `p'
		do
			make (p.host, p.port, p.user, p.password, default_resource, p.server_name)
		end

	make (a_host: like host; a_port: like port;
			a_user: like user; a_passwd: like password;
			a_resource: like resource;
			a_server: like server)
			-- Create connection with host, port, ...
		do
			make_stream (a_host, a_port, False)

				-- Init default
			authed := False
			session_started := False
			auto_subscribe := False
			use_encryption := False

				-- Parameters
			user := a_user
			password := a_passwd
			if a_resource /= Void then
				resource := a_resource
			else
				resource := default_resource
			end

			if not is_server then
				server := host
			end

			base_jid := user + token_aerobase + host
			roster := new_roster
			track_presence := True

			stream_start := "<stream:stream to=%"" + server + "%" xmlns:stream=%"http://etherx.jabber.org/streams%" xmlns=%"jabber:client%" version=%"1.0%">"
			stream_end := "</stream:stream>"
			default_ns := "jabber:client"

			add_xpath_handler ("{http://etherx.jabber.org/streams}features", agent features_handler)
			add_xpath_handler ("{urn:ietf:params:xml:ns:xmpp-sasl}failure", agent sasl_failure_handler)
			add_xpath_handler ("{urn:ietf:params:xml:ns:xmpp-sasl}success", agent sasl_success_handler)
			add_xpath_handler ("{urn:ietf:params:xml:ns:xmpp-tls}proceed", agent tls_proceed_handler)
			add_xpath_handler ("{jabber:client}message", agent message_handler)
			add_xpath_handler ("{jabber:client}presence", agent presence_handler)
			add_xpath_handler ("iq/{jabber:iq:roster}query", agent roster_iq_handler)
		end

feature -- Access

	server: STRING
	user: STRING
	password: STRING
	resource: STRING
	full_jid: STRING
	base_jid: STRING

	authed: BOOLEAN
	session_started: BOOLEAN
	auto_subscribe: BOOLEAN assign set_auto_subscribe
	use_encryption: BOOLEAN
	track_presence: BOOLEAN
	roster: XMPP_ROSTER

feature -- Default value

	default_resource: STRING = "EiffelXMPP"
			-- Default resource's value

feature {NONE} -- Factory

	new_roster: XMPP_ROSTER
			-- Create a new roster
		do
			create Result.make
		end

feature -- Element changes

	set_use_encryption (b: like use_encryption)
		do
			use_encryption := b
		end

	set_auto_subscribe (b: like auto_subscribe)
		do
			auto_subscribe := b
		end

feature -- Basic operations

	message (a_to: STRING; a_body: STRING; a_type: STRING)
			-- Send a message `a_body' of type `a_type' to `a_to'
		local
			l_type: STRING
		do
			l_type := a_type
			if l_type = Void then
				l_type := word_chat
			end
			message_with_details (a_to, a_body, l_type, Void, Void)
		end

	message_with_details (a_to: STRING; a_body: STRING; a_type, a_subject: STRING; a_extra: STRING)
			-- Send a message `a_body' of type `a_type' to `a_to'
			-- with `a_subject' and `a_extra' xml part.
		require
			full_jid_attached: full_jid /= Void
		local
			l_to, l_body: STRING
			msg: STRING
		do
			l_to := htmlspecialchars(a_to)
			l_body := htmlspecialchars(a_body)

			msg := "<message from=%"" + full_jid + "%" to=%""+ l_to +"%" type=%"" + a_type + "%">"
			if a_subject /= Void then
				msg.append ("<subject>" + htmlspecialchars (a_subject) + "</subject>")
			end
			msg.append ("<body>" + l_body + "</body>")
			if a_extra /= Void then
				msg.append (a_extra)
			end
			msg.append ("</message>")
			log ("Message<" + a_type + "> %"" + l_body + "%"%N" +
				 "  - from: " + full_jid + "%N" +
				 "  -   to: " + l_to, {XMPP_LOGGER}.log_info)
			send (msg)
		end

	presence (a_status: STRING)
			-- Send a presence message
		do
			presence_with_details (a_status, word_available, Void, word_available, 0)
		end

	presence_with_details (a_status: STRING; a_show: STRING; a_to: STRING; a_type: STRING; a_priority: INTEGER)
			-- Send a presence request with various details
		local
			l_show, l_type: STRING
			l_status: STRING
			msg: STRING
		do
			l_show := a_show
			if l_show = Void then
				l_show := word_available
			end
			l_type := a_type
			if l_type = Void then
				l_type := word_available
			end
			if l_type.is_equal (word_available) then
				l_type := ""
			end
			if (l_show.is_equal (word_unavailable)) then
				l_type := word_unavailable
			end

			msg := "<presence"
			if a_to /= Void then
				msg.append (" to=%"" + htmlspecialchars (a_to) + "%"")
			end
			l_status := htmlspecialchars(a_status)
			if l_type /= Void then
				msg.append (" type=%"" + l_type + "%"")
			end
			if l_show.is_equal (word_available) and then a_status /= Void then
				msg.append ("/>")
			else
				msg.append (">")
				if not l_show.is_equal (word_available) then
					msg.append ("<show>" + l_show + "</show>")
				end
				if a_status /= Void then
					msg.append ("<status>" + htmlspecialchars (a_status) + "</status>")
				end
				if a_priority > 0 then
					msg.append ("<priority>" + a_priority.out + "</priority>")
				end
				msg.append ("</presence>")
			end
			send (msg)
		end

	get_roster
			-- Get roster
		local
			l_id: like get_id
		do
			l_id := get_id
			send("<iq xmlns=%"jabber:client%" type=%"get%" id=%"" + l_id + "%"><query xmlns=%"jabber:iq:roster%" /></iq>")
		end

	get_vcard (a_jid: STRING)
			-- Get Vcard
		local
			l_id: STRING
		do
			log ("Query Vcard %"" + a_jid + "%" ...", {XMPP_LOGGER}.log_info)
			l_id := get_id
			add_id_handler (l_id, agent vcard_get_handler)
			if a_jid /= Void then
				send("<iq type=%"get%" id=%"" + l_id + "%" to=%"" + a_jid + "%"><vCard xmlns=%"vcard-temp%" /></iq>")
			else
				send("<iq type=%"get%" id=%"" + l_id + "%"><vCard xmlns=%"vcard-temp%" /></iq>")
			end
		end

feature -- Handler

	message_handler (a_xml: XMPP_XML_TAG)
			-- Message event handling
		local
			l_event_data: XMPP_EVENT_DATA
			l_type, l_from: STRING
			l_content: STRING
		do
			log ("Message handled", {XMPP_LOGGER}.log_info)
			create l_event_data.make (event_name_message)
			l_type := a_xml.attribute_value (word_type, word_chat)
			l_event_data.add_variable (word_type, l_type)
			l_from := a_xml.attribute_value (word_from, word_anonymous)
			l_event_data.add_variable (word_from, l_from)
			l_content := a_xml.child_content (word_body, Void)
			l_event_data.add_variable (word_body, l_content)
			l_event_data.set_tag (a_xml)

			if l_content /= Void then
				log ("Message: " + l_content, {XMPP_LOGGER}.log_debug)
			else
				log ("Message: None", {XMPP_LOGGER}.log_debug)
			end
			event (event_name_message, l_event_data)
		end

	presence_handler (a_xml: XMPP_XML_TAG)
			-- Presence event handling
		local
			l_event_data: XMPP_EVENT_DATA
			l_show, l_status, l_priority: STRING
			l_from, l_type: STRING
		do
			log ("Presence handled", {XMPP_LOGGER}.log_info)

			create l_event_data.make (event_name_presence)


				--| Type
			l_type := a_xml.attribute_value (word_type, word_available)
			l_event_data.add_variable (word_type, l_type)

				--| Show
			l_show := a_xml.child_content (word_show, l_type)
			l_event_data.add_variable (word_show, l_show)

				--| From
			l_from := a_xml.attribute_value (word_from, word_anonymous)
			l_event_data.add_variable (word_from, l_from)

				--| Status
			l_status := a_xml.child_content (word_status, "")
			l_event_data.add_variable (word_status, l_status)

				--| Priority
			l_status := a_xml.child_content (word_priority, "0")
			l_event_data.add_variable (word_priority, l_priority)

				-- Xml
			l_event_data.set_tag (a_xml)

			if track_presence then
				roster.set_presence (
						l_event_data.variable (word_from, "from?"),
						l_event_data.variable (word_priority, "priority?") ,
						l_event_data.variable (word_show, "show?") ,
						l_event_data.variable (word_status, "status?")
					)
			end
			log ("Presence " + l_from + " [" + l_show + "] " + l_status, {XMPP_LOGGER}.log_debug)
			if a_xml.attribs.has_key (word_type) and then a_xml.attribs.found_item.is_case_insensitive_equal ("subscribe") then
				if auto_subscribe then
					send ("<presence type=%"subscribed%" to=%"" + a_xml.attribs.item (word_from) + "%" from=%"" + full_jid + "%" />")
					send ("<presence type=%"subscribe%" to=%"" + a_xml.attribs.item (word_from) + "%" from=%"" + full_jid + "%" />")
				end
				l_event_data.set_name (event_name_subscription_requested)
				event (event_name_subscription_requested, l_event_data)
			elseif a_xml.attribs.has_key (word_type) and then a_xml.attribs.found_item.is_case_insensitive_equal ("subscribed") then
				l_event_data.set_name (event_name_subscription_accepted)
				event (event_name_subscription_accepted, l_event_data)
			else
				event (event_name_presence, l_event_data)
			end
		end

	features_handler (a_xml: XMPP_XML_TAG)
			-- Features event handling
		local
			l_id: STRING
			s: STRING
		do
			log ("Features handled", {XMPP_LOGGER}.log_info)
			if a_xml.has_child (word_starttls) and use_encryption then
				send("<starttls xmlns=%"urn:ietf:params:xml:ns:xmpp-tls%"><required /></starttls>")
			elseif a_xml.has_child ("bind") and authed then
				l_id := get_id
				add_id_handler (l_id, agent resource_bind_handler)
				send("<iq xmlns=%"jabber:client%" type=%"set%" id=%"" + l_id + "%"><bind xmlns=%"urn:ietf:params:xml:ns:xmpp-bind%"><resource>" + resource + "</resource></bind></iq>")
			else
				log ("Attempting Auth...", {XMPP_LOGGER}.log_info)
				if password /= Void then
					create s.make_empty
					s.append_character ('%U')
					s.append_string (user)
					s.append_character ('%U')
					s.append_string (password)
					send("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>"
						+ base64_encoded (s)
						+ "</auth>")
				else
					send("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='ANONYMOUS'/>")
				end
			end
		end

	sasl_success_handler (a_xml: XMPP_XML_TAG)
			-- SASL success handler	
		do
			log ("Auth success!", {XMPP_LOGGER}.log_info)
			authed := True
			reset
		end

	sasl_failure_handler (a_xml: XMPP_XML_TAG)
			--	SASL feature handler
		do
			log ("Auth failed!", {XMPP_LOGGER}.log_info)
			disconnect
			raise_xmpp_exception ("Auth failed!")
		end

	resource_bind_handler (a_xml: XMPP_XML_TAG)
			-- Resource bind event handling
		local
			p: INTEGER
			jid: like full_jid
			l_id: STRING
		do
			log ("Resource bind handled", {XMPP_LOGGER}.log_info)
			if
				a_xml.attribs.has_key (word_type)
				and then a_xml.attribs.item (word_type).is_case_insensitive_equal (word_result)
			then
				full_jid := a_xml.child ("bind").child ("jid").content
				log ("Bound to " + full_jid, {XMPP_LOGGER}.log_info)
				p := full_jid.index_of ('/', 1)
				if p > 0 then
					jid := full_jid.substring (1, p - 1)
				end
			end
			l_id := get_id
			add_id_handler (l_id, agent session_start_handler)
			send ("<iq xmlns=%"jabber:client%" type=%"set%" id=%"" + l_id + "%"><session xmlns=%"urn:ietf:params:xml:ns:xmpp-session%" /></iq>")
		end

	roster_iq_handler (a_xml: XMPP_XML_TAG)
			-- Roster iq handler
			-- Gets all packets matching XPath "iq/{jabber:iq:roster}query'
		local
			l_error: BOOLEAN
			l_xmlroster: XMPP_XML_TAG
			l_tag: XMPP_XML_TAG
			l_user: XMPP_USER
			l_contacts: LINKED_LIST [XMPP_USER]
			l_roster: XMPP_ROSTER
		do
			log ("Roster ip handled", {XMPP_LOGGER}.log_info)
			l_xmlroster := a_xml.child (word_query)
			create l_contacts.make
			if
				l_xmlroster /= Void and then
				attached {LIST [XMPP_XML_TAG]} l_xmlroster.childs as l_subs
			then
				from
					l_subs.start
				until
					l_subs.after
				loop
					l_tag := l_subs.item

					if l_tag.localname.is_case_insensitive_equal (word_item) then
						create l_user.make (l_tag.attribute_value (word_jid, Void)) -- Required
						l_user.name := l_tag.attribute_value (word_name, Void) -- May
						l_user.subscription := l_tag.attribute_value (word_subscription, Void)
						if attached {LIST [XMPP_XML_TAG]} l_tag.childs as l_tag_subs then
							from
								l_tag_subs.start
							until
								l_tag_subs.after
							loop
								if l_tag_subs.item.localname.is_case_insensitive_equal (word_group) then
									l_user.add_group (l_tag_subs.item.content)
								end
								l_tag_subs.forth
							end
						end
						l_contacts.force (l_user)
							-- Store for action if no errors happen
					else
						l_error := True
					end
					l_subs.forth
				end
			end
			if not l_error then
				l_roster := roster
				if l_roster = Void then
					create l_roster.make
					roster := l_roster
				end
				from
					l_contacts.start
				until
					l_contacts.after
				loop
					l_roster.add_contact (l_contacts.item)
					l_contacts.forth
				end
			end
			if a_xml.attribute_value (word_type, "").is_case_insensitive_equal (word_set) then
				send ("<iq type=%"reply%" id=%"" + a_xml.attribute_value (word_id, "") + "%" to=%"" + a_xml.attribute_value (word_from, word_anonymous) + "%" />")
			end
		end

	session_start_handler (a_xml: XMPP_XML_TAG)
			-- Session start handler	
		do
			log ("Session started", {XMPP_LOGGER}.log_info);
			session_started := True
			event (event_name_session_start, create {XMPP_EVENT_DATA}.make (event_name_session_start))
		end

	tls_proceed_handler (a_xml: XMPP_XML_TAG)
	 		-- TLS proceed handler
		do
			log ("Starting TLS encryption", {XMPP_LOGGER}.log_info)
			log ("[ERROR] TLS encryption not yet supported!", {XMPP_LOGGER}.log_error)
			check False end
--			stream_socket_enable_crypto($this->socket, true, STREAM_CRYPTO_METHOD_SSLv23_CLIENT);
			reset
		end

	vcard_get_handler (a_xml: XMPP_XML_TAG)
			-- Vcard get event handling
		local
			l_vcard_array: XMPP_EVENT_DATA
			vcard: XMPP_XML_TAG
			l_item: XMPP_XML_TAG
		do
			log ("VCard get handled", {XMPP_LOGGER}.log_info)
			vcard := a_xml.child (word_vcard)
			create l_vcard_array.make (word_vcard)
				--| go through all of the sub elements and add them to the vcard array
			if vcard /= Void and then attached {LIST [XMPP_XML_TAG]} vcard.childs as l_subs then
				from
					l_subs.start
				until
					l_subs.after
				loop
					if
						attached {LIST [XMPP_XML_TAG]} l_subs.item.childs as l_sub_subs and then
						not l_sub_subs.is_empty
					then
						from
							l_sub_subs.start
						until
							l_sub_subs.after
						loop
							l_item := l_sub_subs.item
							l_vcard_array.add_variable (l_item.localname, l_item.content)
							l_sub_subs.forth
						end
					else
						l_item := l_subs.item
						l_vcard_array.add_variable (l_item.localname, l_item.content)
					end
					l_subs.forth
				end
			end
			l_vcard_array.add_variable (word_from, a_xml.attribute_value (word_from, word_anonymous))
			event (word_vcard, l_vcard_array)
		end

feature {NONE} -- Implementation

	htmlspecialchars (s: STRING): STRING
		local
			c: CHARACTER
			i,n: INTEGER
		do
			if s /= Void and then not s.is_empty then
				create Result.make (s.count)
				from
					i := 1
					n := s.count
				until
					i > n
				loop
					c := s.item (i)
					inspect c
					when '&' then
						Result.append_string (html_amp)
					when '%"' then
						Result.append_string (html_double_quot)
					when '%'' then
						Result.append_string (html_single_quot)
					when '<' then
						Result.append_string (html_lt)
					when '>' then
						Result.append_string (html_gt)
					else
						Result.append_character (c)
					end
					i := i + 1
				end
			end
		end

	html_amp: STRING = "&amp;"
	html_double_quot: STRING = "&quot;"
	html_single_quot: STRING = "&#039;"
	html_lt: STRING = "&lt;"
	html_gt: STRING = "&gt;"

	token_aerobase: STRING = "@"

	word_from: STRING = "from"
	word_anonymous: STRING = "anonymous"
	word_type: STRING = "type"
	word_vcard: STRING = "vcard"
	word_set: STRING = "set"
	word_show: STRING = "show"
	word_status: STRING = "status"
	word_priority: STRING = "priority"
	word_group: STRING = "group"
	word_item: STRING = "item"
	word_jid: STRING = "jid"
	word_id: STRING = "id"
	word_name: STRING = "name"
	word_query: STRING = "query"
	word_subscription: STRING = "subscription"
	word_result: STRING = "result"
	word_starttls: STRING = "result"
	word_chat: STRING = "chat"
	word_body: STRING = "body"
	word_available: STRING = "available"
	word_unavailable: STRING = "unavailable"


note
	copyright: "Copyright (c) 2003-2011, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
