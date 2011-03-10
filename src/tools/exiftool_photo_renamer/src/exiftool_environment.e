note
	description: "Summary description for {EXIFTOOL_ENVIRONMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXIFTOOL_ENVIRONMENT

feature -- Access

	executable_path: STRING = "c:\apps\photo\exiftool"

	executable_filename: STRING
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (executable_path)
			fn.set_file_name ("exiftool.exe")
			Result := fn.string
		end

end
