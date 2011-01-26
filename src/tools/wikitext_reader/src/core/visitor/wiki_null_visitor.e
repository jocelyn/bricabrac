note
	description: "Summary description for {WIKI_DEBUG_VISITOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_NULL_VISITOR

inherit
	WIKI_VISITOR

feature -- Processing

	process_composite (a_composite: WIKI_COMPOSITE [WIKI_ITEM])
		do
		end

	process_structure (a_structure: WIKI_STRUCTURE)
		do
		end

	process_section (a_section: WIKI_SECTION)
		do
		end

	process_paragraph (a_paragraph: WIKI_PARAGRAPH)
		do
		end

	process_list (a_list: WIKI_LIST)
		do
		end

	process_list_item (a_list_item: WIKI_LIST_ITEM)
		do
		end

	process_preformatted_text (a_block: WIKI_PREFORMATTED_TEXT)
		do
		end

--	process_indented_text (a_text: WIKI_INDENTED_TEXT)
--		do
--		end

	process_line (a_line: WIKI_LINE)
		do
		end

	process_line_separator (a_sep: WIKI_LINE_SEPARATOR)
		do
		end

	process_string (a_string: WIKI_STRING)
		do
		end

feature -- Strings

	process_raw_string (a_raw_string: WIKI_RAW_STRING)
		do
		end

	process_style (a_style: WIKI_STYLE)
		do
		end

	process_comment (a_comment: WIKI_COMMENT)
		do
		end

feature -- Template

	process_template (a_template: WIKI_TEMPLATE)
		do
		end

feature -- Links

	process_external_link (a_link: WIKI_EXTERNAL_LINK)
		do
		end

	process_link (a_link: WIKI_LINK)
		do
		end

	process_image_link (a_link: WIKI_IMAGE_LINK)
		do
		end

	process_category_link (a_link: WIKI_CATEGORY_LINK)
		do
		end

	process_media_link (a_link: WIKI_MEDIA_LINK)
		do
		end

feature -- Table

	process_table (a_table: WIKI_TABLE)
		do
		end

	process_table_row (a_row: WIKI_TABLE_ROW)
		do
		end

	process_table_cell (a_cell: WIKI_TABLE_CELL)
		do
		end

end
