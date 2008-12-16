note
	description: "Summary description for {XMPP_XML_TAG}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_XML_TAG

create
	make

feature {NONE} -- Initialization

	make (a_namespace: STRING_8; a_prefix: STRING_8; a_local_part: STRING_8; a_depth: INTEGER)
		do
			namespace := a_namespace
			prefixname := a_prefix
			localname := a_local_part
			if a_prefix /= Void then
				name := a_prefix + "." + a_local_part
			else
				name := a_local_part
			end
			depth := a_depth

			create attribs.make (10)
			attribs.compare_objects
			create {LINKED_LIST [XMPP_XML_TAG]} childs.make
			create content.make_empty
		end

feature -- Access

	namespace: STRING
	prefixname: STRING
	localname: STRING

	depth: INTEGER

	name: STRING
	attribs: HASH_TABLE [STRING, STRING] -- name => value
	content: STRING
	childs: LIST [XMPP_XML_TAG]

feature -- Query

	has_child (n: STRING): BOOLEAN
		do
			from
				childs.start
			until
				childs.after or Result
			loop
				Result := childs.item.localname.is_case_insensitive_equal (n)
				childs.forth
			end
		end

	child (n: STRING): XMPP_XML_TAG
		do
			from
				childs.start
			until
				childs.after or Result /= Void
			loop
				if childs.item.localname.is_case_insensitive_equal (n) then
					Result := childs.item
				end
				childs.forth
			end
		end

	attribute_value (n, d: STRING): STRING
		do
			if attribs.has_key (n) then
				Result := attribs.found_item
			else
				Result := d
			end
		end

	child_content (n, d: STRING): STRING
		do
			if {l_tag: like child} child (n) then
				Result := l_tag.content
			end
			if Result = Void then
				Result := d
			end
		end

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.net/
		]"
end
