note
	description: "Summary description for {EXIFTOOL_RENAMING_CONFIGURATION}."
	date: "$Date$"
	revision: "$Revision$"

class
	EXIFTOOL_RENAMING_CONFIGURATION

create
	make

feature {NONE} -- Initialization

	make
		do
			set_output_directory (".")
		end

feature -- Access

	output_directory_is_default: BOOLEAN
		do
			Result := output_directory.same_string (".")
		end

	output_directory: STRING

	output_folder_template: detachable STRING

	output_filename_template: detachable STRING

	prefix_name: detachable STRING

	lower_extension: BOOLEAN

	upper_extension: BOOLEAN

	is_simulation: BOOLEAN

	verbose_level: INTEGER

	is_verbose (n: INTEGER): BOOLEAN
		do
			Result := n <= verbose_level
		end

	remove_file: BOOLEAN

feature -- Element change

	set_output_directory (v: like output_directory)
		do
			output_directory := v
		end

	set_output_folder_template (v: like output_folder_template)
		do
			output_folder_template := v
		end

	set_output_filename_template (v: like output_filename_template)
		do
			output_filename_template := v
		end

	set_prefix_name (v: like prefix_name)
		do
			prefix_name := v
		end

	set_lower_extension (v: like lower_extension)
		do
			if v then
				upper_extension := False
			end
			lower_extension := v
		end

	set_upper_extension (v: like upper_extension)
		do
			if v then
				lower_extension := False
			end
			upper_extension := v
		end

	set_is_simulation (v: like is_simulation)
		do
			is_simulation := v
		end

	set_verbose_level (v: like verbose_level)
		do
			verbose_level := v
		end

	set_remove_file (v: like remove_file)
		do
			remove_file := v
		end

end
