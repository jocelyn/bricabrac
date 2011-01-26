note
	description: "Summary description for {WIKI_VISITOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WIKI_VISITOR

feature -- Processing

	process_composite (a_composite: WIKI_COMPOSITE [WIKI_ITEM])
		require
			a_composite_attached: a_composite /= Void
		deferred
		end

	process_structure (a_structure: WIKI_STRUCTURE)
		require
			a_structure_attached: a_structure /= Void
		deferred
		end

	process_section (a_section: WIKI_SECTION)
		require
			a_section_attached: a_section /= Void
		deferred
		end

	process_paragraph (a_paragraph: WIKI_PARAGRAPH)
		require
			a_paragraph_attached: a_paragraph /= Void
		deferred
		end

	process_list (a_list: WIKI_LIST)
		require
			a_list_attached: a_list /= Void
		deferred
		end

	process_list_item (a_item: WIKI_LIST_ITEM)
		require
			a_item_attached: a_item /= Void
		deferred
		end

	process_preformatted_text (a_block: WIKI_PREFORMATTED_TEXT)
		require
			a_block_attached: a_block /= Void
		deferred
		end

--	process_indented_text (a_text: WIKI_INDENTED_TEXT)
--		require
--			a_text_attached: a_text /= Void
--		deferred
--		end

	process_line (a_line: WIKI_LINE)
		require
			a_line_attached: a_line /= Void
		deferred
		end

	process_line_separator (a_sep: WIKI_LINE_SEPARATOR)
		require
			a_sep_attached: a_sep /= Void
		deferred
		end

	process_string (a_string: WIKI_STRING)
		require
			a_string_attached: a_string /= Void
		deferred
		end

feature -- Strings

	process_raw_string (a_raw_string: WIKI_RAW_STRING)
		require
			a_raw_string_attached: a_raw_string /= Void
		deferred
		end

	process_style (a_style: WIKI_STYLE)
		require
			a_style_attached: a_style /= Void
		deferred
		end

	process_comment (a_comment: WIKI_COMMENT)
		require
			a_comment_attached: a_comment /= Void
		deferred
		end

feature -- Template

	process_template (a_template: WIKI_TEMPLATE)
		require
			a_template_attached: a_template /= Void
		deferred
		end

feature -- Links

	process_external_link (a_link: WIKI_EXTERNAL_LINK)
		require
			a_link_attached: a_link /= Void
		deferred
		end

	process_link (a_link: WIKI_LINK)
		require
			a_link_attached: a_link /= Void
		deferred
		end

	process_image_link (a_link: WIKI_IMAGE_LINK)
		require
			a_link_attached: a_link /= Void
		deferred
		end

	process_category_link (a_link: WIKI_CATEGORY_LINK)
		require
			a_link_attached: a_link /= Void
		deferred
		end

	process_media_link (a_link: WIKI_MEDIA_LINK)
		require
			a_link_attached: a_link /= Void
		deferred
		end

feature -- Table

	process_table (a_table: WIKI_TABLE)
		require
			a_table_attached: a_table /= Void
		deferred
		end

	process_table_row (a_row: WIKI_TABLE_ROW)
		require
			a_row_attached: a_row /= Void
		deferred
		end

	process_table_cell (a_cell: WIKI_TABLE_CELL)
		require
			a_cell_attached: a_cell /= Void
		deferred
		end


end
