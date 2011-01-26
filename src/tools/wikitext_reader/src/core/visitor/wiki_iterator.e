note
	description: "Summary description for {WIKI_DEBUG_VISITOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_ITERATOR

inherit
	WIKI_VISITOR

feature -- Processing

	process_composite (a_composite: WIKI_COMPOSITE [WIKI_ITEM])
		local
			elts: like {WIKI_COMPOSITE [WIKI_ITEM]}.elements
		do
			elts := a_composite.elements
			if elts.count > 0 then
				from
					elts.start
				until
					elts.after
				loop
					elts.item.process (Current)
					elts.forth
				end
			end
		end

	process_structure (a_structure: WIKI_STRUCTURE)
		do
			process_composite (a_structure)
		end

	process_section (a_section: WIKI_SECTION)
		do
			if attached a_section.text as t then
				t.process (Current)
			end
			process_composite (a_section)
		end

	process_paragraph (a_paragraph: WIKI_PARAGRAPH)
		do
			process_composite (a_paragraph)
		end

	process_list (a_list: WIKI_LIST)
		do
			process_composite (a_list)
		end

	process_list_item (a_list_item: WIKI_LIST_ITEM)
		do
			if attached a_list_item.text as t then
				t.process (Current)
			end
			process_composite (a_list_item)
		end

	process_preformatted_text (a_block: WIKI_PREFORMATTED_TEXT)
		do
			process_composite (a_block)
		end

--	process_indented_text (a_text: WIKI_INDENTED_TEXT)
--		do
--			a_text.text.process (Current)
--			process_composite (a_text)
--		end

	process_line (a_line: WIKI_LINE)
		do
			a_line.text.process (Current)
		end

	process_line_separator (a_sep: WIKI_LINE_SEPARATOR)
		do
		end

	process_string (a_string: WIKI_STRING)
		do
			if attached a_string.parts as l_parts then
				process_composite (l_parts)
			end
		end

feature -- Strings

	process_raw_string (a_raw_string: WIKI_RAW_STRING)
		do
		end

	process_style (a_style: WIKI_STYLE)
		do
			a_style.text.process (Current)
		end

	process_comment (a_comment: WIKI_COMMENT)
		do
		end

feature -- Template

	process_template (a_template: WIKI_TEMPLATE)
		do
			if attached a_template.parameters_string as pstr then
				pstr.process (Current)
			end
		end

feature -- Links

	process_external_link (a_link: WIKI_EXTERNAL_LINK)
		do
			a_link.text.process (Current)
		end

	process_link (a_link: WIKI_LINK)
		do
			a_link.text.process (Current)
		end

	process_image_link (a_link: WIKI_IMAGE_LINK)
		do
			a_link.text.process (Current)
		end

	process_category_link (a_link: WIKI_CATEGORY_LINK)
		do
			a_link.text.process (Current)
		end

	process_media_link (a_link: WIKI_MEDIA_LINK)
		do
			a_link.text.process (Current)
		end

feature -- Table

	process_table (a_table: WIKI_TABLE)
		do
			process_composite (a_table)
		end

	process_table_row (a_row: WIKI_TABLE_ROW)
		do
			process_composite (a_row)
		end

	process_table_cell (a_cell: WIKI_TABLE_CELL)
		do
			a_cell.text.process (Current)
		end

end
