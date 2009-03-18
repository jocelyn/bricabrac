note
	description: "Summary description for {TWITTER_JSON}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	TWITTER_JSON

inherit
	TWITTER_I

create
	make,
	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: STRING)
		do
			create twitter_api.make (a_username, a_password)
			twitter_api.set_json_format
		end

	make_with_source (a_username, a_password: STRING; a_source: STRING)
		do
			make (a_username, a_password)
			twitter_api.set_application_source (a_source)
		end

feature -- Twitter: Status Methods

	public_timeline: detachable LIST [TWITTER_STATUS]
		do
			if attached twitter_api.public_timeline as s then
				if attached parsed_json (s) as j then
					Result := twitter_statuses (Void, j)
				end
			end
		end

	friends_timeline (a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): detachable LIST [TWITTER_STATUS]
		do
			if attached twitter_api.friends_timeline (a_since_date, a_since_id, a_count, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_statuses (Void, j)
				end
			end
		end

	user_timeline (a_id: INTEGER; a_screen_name: detachable STRING; a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): detachable LIST [TWITTER_STATUS]
		do
			if attached twitter_api.user_timeline (a_id, a_screen_name, a_since_date, a_since_id, a_count, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_statuses (Void, j)
				end
			end
		end

	status (a_id: INTEGER): detachable TWITTER_STATUS
			-- single status, specified by the id parameter below.
			-- The status's author will be returned inline.
		do
			if attached twitter_api.show_status (a_id) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

	update_status (a_status: STRING; in_reply_to_status_id: INTEGER): detachable TWITTER_STATUS
			-- Updates the authenticating user's status.
		do
			if attached twitter_api.update_status (a_status, in_reply_to_status_id) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

	replies (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_STATUS]
			--Returns the 20 most recent @replies (status updates prefixed with @username) for the authenticating user.
			--URL: http://twitter.com/statuses/replies.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * page.  Optional. Retrieves the 20 next most recent replies.  Ex: http://twitter.com/statuses/replies.xml?page=3
			--    * since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date, up to 24 hours old.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/replies.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/replies.xml?since_id=12345
			--Returns: list of status elements		
		do
			if attached twitter_api.replies (a_since_date, a_since_id, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_statuses (Void, j)
				end
			end
		end

	destroy_status (a_id: INTEGER): detachable TWITTER_STATUS
			--Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
			--URL: http://twitter.com/statuses/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the status to destroy.  Ex: http://twitter.com/statuses/destroy/12345.json or http://twitter.com/statuses/destroy/23456.xml
			--Returns: status element		
		do
			if attached twitter_api.destroy_status (a_id) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

feature -- Twitter: User Methods

	friends (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_USER]
		do
			if attached twitter_api.friends (a_id, a_screen_name, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_users (Void, j)
				end
			end
		end

	followers (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_USER]
		do
			if attached twitter_api.followers (a_id, a_screen_name, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_users (Void, j)
				end
			end
		end

	user (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.show_user (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

feature -- Twitter: Direct Message Methods

	direct_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_MESSAGE]
		do
			if attached twitter_api.direct_messages (a_since_date, a_since_id, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_messages (Void, j)
				end
			end
		end

	sent_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_MESSAGE]
		do
			if attached twitter_api.sent_messages (a_since_date, a_since_id, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_messages (Void, j)
				end
			end
		end

	new_message (a_user: STRING; a_text: STRING): detachable TWITTER_MESSAGE
		do
			if attached twitter_api.new_message (a_user, a_text) as s then
				if attached parsed_json (s) as j then
					Result := twitter_message (Void, j)
				end
			end
		end

	destroy_message (a_id: INTEGER): detachable LIST [TWITTER_MESSAGE]
		do
			if attached twitter_api.destroy_message (a_id) as s then
				if attached parsed_json (s) as j then
					Result := twitter_messages (Void, j)
				end
			end
		end

feature -- Twitter: Friendship Methods

	create_friendship (a_id: INTEGER; a_screen_name: detachable STRING; a_follow: BOOLEAN): detachable TWITTER_USER
		do
			if attached twitter_api.create_friendship (a_id, a_screen_name, a_follow) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	destroy_friendship (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.destroy_friendship (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	friendship_exists (a_id: INTEGER; a_screen_name: detachable STRING;
					b_id: INTEGER; b_screen_name: detachable STRING): BOOLEAN
		do
			if attached twitter_api.friendship_exists (a_id, a_screen_name, b_id, b_screen_name) as s then
				if attached parsed_json (s) as j then
--					Result := twitter_user (Void, j)
				end
			end
		end

feature -- Twitter: Social Graph Methods

	friends_ids (a_id: INTEGER; a_screen_name: detachable STRING): detachable LIST [INTEGER]
		do
			to_implement ("not yet supported")
		end

	followers_ids (a_id: INTEGER; a_screen_name: detachable STRING): detachable LIST [INTEGER]
		do
			to_implement ("not yet supported")
		end

feature -- Twitter: Account Methods

	verify_credentials: detachable TWITTER_USER
		local
			err: DEVELOPER_EXCEPTION
		do
			if attached twitter_api.verify_credentials as s then
				if attached parsed_json (s) as j then
					if attached string_value_from_json (j, "error") as l_error then
						create err
						err.set_message (l_error)
						err.raise
					else
						Result := twitter_user (Void, j)
					end
				end
			end
		end

	end_session
		local
			s: STRING
		do
			s := twitter_api.end_session
		end

	update_delivery_device (a_device: STRING): detachable TWITTER_USER
		do
			if attached twitter_api.update_delivery_device (a_device) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	update_profile (a_name, a_email, a_url, a_location, a_description: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.update_profile (a_name, a_email, a_url, a_location, a_description) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	update_profile_colors (a_profile_background_color, a_profile_text_color, a_profile_link_color,
					a_profile_sidebar_fill_color, a_profile_sidebar_border_color: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.update_profile (a_profile_background_color, a_profile_text_color, a_profile_link_color,
					a_profile_sidebar_fill_color, a_profile_sidebar_border_color) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	update_profile_image (a_image: STRING): detachable TWITTER_USER
		do
			to_implement ("not yet supported")
		end

	update_profile_background_image (a_image: STRING): detachable TWITTER_USER
		do
			to_implement ("not yet supported")
		end

	rate_limit_status: detachable TUPLE [ reset_time_in_seconds: INTEGER; remaining_hits: INTEGER; hourly_limit: INTEGER; reset_time: detachable STRING]
			-- <Precursor/>
			--| Ex:{"reset_time_in_seconds":1237292716,"remaining_hits":100,"hourly_limit":100,"reset_time":"Tue Mar 17 12:25:16 +0000 2009"}			
		do
			if attached twitter_api.rate_limit_status as s then
				if attached parsed_json (s) as j then
					create Result
					Result.reset_time_in_seconds := integer_value_from_json (j, "reset_time_in_seconds")
					Result.remaining_hits := integer_value_from_json (j, "remaining_hits")
					Result.hourly_limit := integer_value_from_json (j, "hourly_limit")
					Result.reset_time := string_value_from_json (j, "reset_time")
				end
			end
		end

feature -- Twitter: favorite Methods

	favorites (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_STATUS]
		do
			if attached twitter_api.favorites (a_id, a_screen_name, a_page) as s then
				if attached parsed_json (s) as j then
					Result := twitter_statuses (Void, j)
				end
			end
		end

	create_favorite (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_STATUS
		do
			if attached twitter_api.create_favorite (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

	destroy_favorite (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_STATUS
		do
			if attached twitter_api.destroy_favorite (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

feature -- Twitter: Notification Methods

	follow (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.follow (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	leave (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.leave (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

feature -- Twitter: Block Methods

	create_block (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.create_block (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

	destroy_block (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
		do
			if attached twitter_api.destroy_block (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

feature -- Twitter: Help Methods

	test: detachable STRING
		do
			Result := twitter_api.test
		end

feature -- Implementation: Factory

	twitter_status (a_status: detachable like twitter_status; a_json: JSON_VALUE): TWITTER_STATUS
			-- Fill `a_status' from `a_json'
		require
			a_json_attached: a_json /= Void
		do
			if a_status /= Void then
				Result := a_status
			else
				create Result
			end
			Result.set_id (integer_value_from_json (a_json, "id"))
			Result.set_text (string_value_from_json (a_json, "text"))
			Result.set_in_reply_to_user_id (integer_value_from_json (a_json, "in_reply_to_user_id"))
			Result.set_in_reply_to_status_id (integer_value_from_json (a_json, "in_reply_to_status_id"))
			Result.set_in_reply_to_screen_name (string_value_from_json (a_json, "in_reply_to_screen_name"))
			Result.set_created_at (string_value_from_json (a_json, "created_at"))
			Result.set_truncated (boolean_value_from_json (a_json, "truncated"))
			Result.set_favorited (boolean_value_from_json (a_json, "favorited"))
			Result.set_source (string_value_from_json (a_json, "source"))

			if attached {JSON_OBJECT} json_value (a_json, "user") as l_user then
				Result.set_user (twitter_user (Void, l_user))
			end
		end

	twitter_user (a_user: detachable like twitter_user; a_json: JSON_VALUE): TWITTER_USER
			-- Fill `a_user' from `a_json'
		require
			a_json_attached: a_json /= Void
		do
			if a_user /= Void then
				Result := a_user
			else
				create Result
			end
			Result.set_id (integer_value_from_json (a_json, "id"))
			Result.set_created_at (string_value_from_json (a_json, "created_at"))
			Result.set_name (string_value_from_json (a_json, "name"))
			Result.set_screen_name (string_value_from_json (a_json, "screen_name"))
			if attached string_value_from_json (a_json, "location") as s then
				Result.set_location (twitter_api.stripslashes (s))
			else
				Result.set_location (Void)
			end
			Result.set_description (string_value_from_json (a_json, "description"))
			Result.set_profile_image_url (string_value_from_json (a_json, "profile_image_url"))
			Result.set_url (string_value_from_json (a_json, "url"))
			Result.set_protected (boolean_value_from_json (a_json, "protected"))
			Result.set_followers_count (integer_value_from_json (a_json, "followers_count"))

			if attached {JSON_OBJECT} json_value (a_json, "status") as l_status then
				Result.set_status (twitter_status (Void, l_status))
			end
		end

	twitter_message (a_message: detachable like twitter_message; a_json: JSON_VALUE): TWITTER_MESSAGE
			-- Fill `a_message' from `a_json'
		require
			a_json_attached: a_json /= Void
		do
			if a_message /= Void then
				Result := a_message
			else
				create Result
			end

			Result.set_id (integer_value_from_json (a_json, "id"))
			Result.set_sender_id (integer_value_from_json (a_json, "sender_id"))
			Result.set_text (string_value_from_json (a_json, "text"))
			Result.set_recipient_id (integer_value_from_json (a_json, "recipient_id"))
			Result.set_created_at (string_value_from_json (a_json, "created_at"))
			Result.set_sender_screen_name (string_value_from_json (a_json, "sender_screen_name"))
			Result.set_recipient_screen_name (string_value_from_json (a_json, "recipient_screen_name"))

			if attached {JSON_OBJECT} json_value (a_json, "sender") as l_sender then
				Result.set_sender (twitter_user (Void, l_sender))
			end
			if attached {JSON_OBJECT} json_value (a_json, "recipient") as l_recipient then
				Result.set_recipient (twitter_user (Void, l_recipient))
			end
		end

	twitter_statuses (a_statuses: detachable like twitter_statuses; a_json: JSON_VALUE): detachable LIST [TWITTER_STATUS]
		require
			a_json_attached: a_json /= Void
		local
			i: INTEGER
		do
			if attached {JSON_ARRAY} a_json as l_array then
				from
					create {ARRAYED_LIST [TWITTER_STATUS]} Result.make (l_array.count)
					i := 1
				until
					i > l_array.count
				loop
					Result.force (twitter_status (Void, l_array.i_th (i)))
					i := i + 1
				end
			end
		end

	twitter_users (a_users: detachable like twitter_users; a_json: JSON_VALUE): detachable LIST [TWITTER_USER]
		require
			a_json_attached: a_json /= Void
		local
			i: INTEGER
		do
			if attached {JSON_ARRAY} a_json as l_array then
				from
					create {ARRAYED_LIST [TWITTER_USER]} Result.make (l_array.count)
					i := 1
				until
					i > l_array.count
				loop
					Result.force (twitter_user (Void, l_array.i_th (i)))
					i := i + 1
				end
			end
		end

	twitter_messages (a_messages: detachable like twitter_messages; a_json: JSON_VALUE): detachable LIST [TWITTER_MESSAGE]
		require
			a_json_attached: a_json /= Void
		local
			i: INTEGER
		do
			if attached {JSON_ARRAY} a_json as l_array then
				from
					create {ARRAYED_LIST [TWITTER_MESSAGE]} Result.make (l_array.count)
					i := 1
				until
					i > l_array.count
				loop
					Result.force (twitter_message (Void, l_array.i_th (i)))
					i := i + 1
				end
			end
		end

feature -- Implementation

	print_last_json_data
			-- Print `last_json' data
		do
			internal_print_json_data (last_json, "  ")
		end

feature {NONE} -- Implementation

	twitter_api: TWITTER_API
			-- Twitter object

	last_json: detachable JSON_VALUE

	parsed_json (a_json_text: STRING): detachable JSON_VALUE
		local
			j: JSON_PARSER
		do
			create j.make_parser (a_json_text)
			Result := j.parse_json
			last_json := Result
		end

	json_value (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable JSON_VALUE
		local
			l_id: JSON_STRING
			l_ids: LIST [STRING]
		do
			Result := a_json_data
			if Result /= Void then
				if a_id /= Void and then not a_id.is_empty then
					from
						l_ids := a_id.split ('.')
						l_ids.start
					until
						l_ids.after or Result = Void
					loop
						create l_id.make_json (l_ids.item)
						if attached {JSON_OBJECT} Result as v_data then
							if v_data.has_key (l_id) then
								Result := v_data.item (l_id)
							else
								Result := Void
							end
						else
							Result := Void
						end
						l_ids.forth
					end
				end
			end
		end

	internal_print_json_data (a_json_data: detachable JSON_VALUE; a_offset: STRING)
		local
			obj: HASH_TABLE [JSON_VALUE, JSON_STRING]
		do
			if attached {JSON_OBJECT} a_json_data as v_data then
				obj	:= v_data.map_representation
				from
					obj.start
				until
					obj.after
				loop
					print (a_offset)
					print (obj.key_for_iteration.item)
					if attached {JSON_STRING} obj.item_for_iteration as j_s then
						print (": " + j_s.item)
					elseif attached {JSON_NUMBER} obj.item_for_iteration as j_n then
						print (": " + j_n.item)
					elseif attached {JSON_BOOLEAN} obj.item_for_iteration as j_b then
						print (": " + j_b.item.out)
					elseif attached {JSON_NULL} obj.item_for_iteration as j_null then
						print (": NULL")
					elseif attached {JSON_ARRAY} obj.item_for_iteration as j_a then
						print (": {%N")
						internal_print_json_data (j_a, a_offset + "  ")
						print (a_offset + "}")
					elseif attached {JSON_OBJECT} obj.item_for_iteration as j_o then
						print (": {%N")
						internal_print_json_data (j_o, a_offset + "  ")
						print (a_offset + "}")
					end
					print ("%N")
					obj.forth
				end
			end
		end

	integer_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): INTEGER
		do
			if
				attached {JSON_NUMBER} json_value (a_json_data, a_id) as v and then
				v.numeric_type = v.integer_type
			then
				Result := v.item.to_integer
			end
		end

	boolean_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): BOOLEAN
		do
			if attached {JSON_BOOLEAN} json_value (a_json_data, a_id) as v then
				Result := v.item
			end
		end

	string_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable STRING
		do
			if attached {JSON_STRING} json_value (a_json_data, a_id) as v then
				Result := v.item
			end
		end

note
	copyright: "Copyright (c) 2003-2009, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
