note
	description: "Summary description for {ARGUMENTS_FOLDER_VALIDATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARGUMENTS_FOLDER_VALIDATOR

inherit
	ARGUMENT_VALUE_VALIDATOR

feature {NONE} -- Validation

	validate_value (a_value: READABLE_STRING_8)
			-- <Precursor>
		local
			d: like tmp_dir
		do
			d := tmp_dir
			if d = Void then
				create d.make (a_value)
				tmp_dir := d
			else
				d.make (a_value)
			end
			if not d.exists then
				invalidate_option (a_value + " is not a valid folder.")
			end
		end

	tmp_dir: detachable DIRECTORY

end
