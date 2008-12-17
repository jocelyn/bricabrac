note
	description: "Summary description for {XMPP_XML_PARSER}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_XML_PARSER

inherit
	XM_CALLBACKS

create
	make

feature {NONE} -- Initialization

	make
		do

		end

feature -- Access

	start_xml_agent: PROCEDURE [ANY, TUPLE [XMPP_XML_TAG]]

	end_xml_agent: PROCEDURE [ANY, TUPLE [XMPP_XML_TAG]]

feature -- Element change

	reset
		do
			if {lst: like tag_list} tag_list then
				lst.wipe_out
			end
			last_depth := 0
		end

	set_xml_agents (s: like start_xml_agent; e: like end_xml_agent)
			-- Set xml element call backs
		do
			start_xml_agent := s
			end_xml_agent := e
		end

feature {NONE} -- Document

	on_start is
			-- Forward start.
		do
			create tag_list.make (3)
			last_depth := 0
		end

	on_finish is
			-- Forward finish.
		do
		end

	on_xml_declaration (a_version: STRING; an_encoding: STRING; a_standalone: BOOLEAN) is
			-- XML declaration.
		do
		end

feature {NONE} -- Errors

	on_error (a_message: STRING) is
			-- Event producer detected an error.
		do
		end

feature {NONE} -- Meta

	on_processing_instruction (a_name, a_content: STRING) is
			-- Forward PI.
		do
		end

	on_comment (a_content: STRING) is
			-- Forward comment.
		do
		end

feature {NONE} -- Tag

	last_depth: INTEGER

	tag_list: ARRAYED_LIST [like current_tag]

	push_tag (t: like current_tag)
		do
			tag_list.force (t)
		end

	pop_tag: like current_tag
		do
			if {lst: like tag_list} tag_list and then not lst.is_empty then
				lst.finish
				Result := lst.item
				lst.remove
			end
		end

	current_tag: XMPP_XML_TAG
		do
			if not tag_list.is_empty then
				Result := tag_list.last
			end
		end

	on_start_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- Start of start tag.
		local
			p, t: like current_tag
		do
			p := current_tag
			last_depth := last_depth + 1
			create t.make (a_namespace, a_prefix, a_local_part, last_depth)
			push_tag (t)
			if p /= Void then
				p.childs.force (t)
			end
			if {ag: like start_xml_agent} start_xml_agent then
				ag.call ([t])
			end
		end

	on_attribute (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING; a_value: STRING) is
			-- Process attribute.
		do
			if {t: like current_tag} current_tag then
				t.attribs.force (a_value, a_local_part.as_lower)
			end
		end

	on_start_tag_finish is
			-- End of start tag.
		do
--			if {t: like current_tag} current_tag then
--				print (t.name + "%N")
--			end
		end

	on_end_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- End tag.
		do
			last_depth := last_depth - 1
			if {t: like pop_tag} pop_tag then
				if {ag: like end_xml_agent} end_xml_agent then
					ag.call ([t])
				end
			end
--			if on_end_tag_callback /= Void then
--				on_end_tag_callback.call ([a_namespace, a_prefix, a_local_part])
--			end
		end

feature {NONE} -- Content

	on_content (a_content: STRING) is
			-- Forward content.
		do
			if {t: like current_tag} current_tag then
				t.content.append (a_content)
			end
		end

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
