note
	description: "Summary description for {XMPP_XML_TAG}."
	author: "Jocelyn Fiat"
	date: "$Date: 2008-12-17 18:27:29 +0100 (Wed, 17 Dec 2008) $"
	revision: "$Revision: 7 $"

class
	XMPP_XML_TAG

create
	make

feature {NONE} -- Initialization

	make (a_namespace: detachable READABLE_STRING_32; a_prefix: detachable READABLE_STRING_32; a_local_part: READABLE_STRING_32; a_depth: INTEGER)
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

	namespace: detachable READABLE_STRING_32
	prefixname: detachable READABLE_STRING_32
	localname: READABLE_STRING_32

	depth: INTEGER

	name: READABLE_STRING_32
	attribs: STRING_TABLE [READABLE_STRING_32] -- name => value
	content: STRING_32
	childs: LIST [XMPP_XML_TAG]

feature -- Query

	has_child (n: READABLE_STRING_GENERAL): BOOLEAN
		do
			from
				childs.start
			until
				childs.after or Result
			loop
				Result := n.is_case_insensitive_equal (childs.item.localname)
				childs.forth
			end
		end

	child (n: READABLE_STRING_GENERAL): XMPP_XML_TAG
		do
			from
				childs.start
			until
				childs.after or Result /= Void
			loop
				if n.is_case_insensitive_equal (childs.item.localname) then
					Result := childs.item
				end
				childs.forth
			end
		end

	attribute_value (n, d: READABLE_STRING_GENERAL): READABLE_STRING_32
		do
			if attribs.has_key (n) then
				Result := attribs.found_item
			else
				Result := d.as_string_32
			end
		end

	child_content (n, d: READABLE_STRING_GENERAL): READABLE_STRING_32
		do
			if attached child (n) as l_tag then
				Result := l_tag.content
			end
			if Result = Void then
				Result := d.as_string_32
			end
		end

note
	copyright: "Copyright (c) 2003-2016, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
