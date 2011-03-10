note
	description: "Summary description for {EXIFTOOL_ARGUMENT_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXIFTOOL_ARGUMENT_PARSER

inherit
	ARGUMENT_MULTI_PARSER

create
	make

feature {NONE} -- Access

	name: STRING = "photo_renamer"

	switches: ARRAYED_LIST [ARGUMENT_SWITCH]
		local
			l_as: ARGUMENT_SWITCH
		do
			create Result.make (4)
			Result.force (create {ARGUMENT_SWITCH}.make (simulation_switch, "Simulation mode", True, False))
			Result.force (create {ARGUMENT_SWITCH}.make (output_dir_switch, "Output directory", True, False))
			Result.force (create {ARGUMENT_VALUE_SWITCH}.make (config_switch, "Configuration file", True, False, "filename", "path to the configuration file", True))
--			Result.force (create {ARGUMENT_VALUE_SWITCH}.make (lang_switch, "Interface language", True, False, "language", "fr:francais en:english ... (default=en)", True))
			Result.force (create {ARGUMENT_VALUE_SWITCH}.make_hidden (lang_switch, True, False, "language", True))
		end

	version: STRING = "0.1"

	non_switched_argument_description: STRING_8 = "Folder containing the pictures"
			-- <Precursor>

	non_switched_argument_name: STRING_8 = "picture-folder"
			-- <Precursor>

	non_switched_argument_type: STRING_8 = "string"
			-- <Precursor>	

feature {NONE} -- Access

	simulation_switch: STRING = "n|simulation"
	output_dir_switch: STRING = "o|output-dir"
	config_switch: STRING = "c|configuration"
	lang_switch: STRING = "lang"


feature -- Status report

	has_simulation: BOOLEAN
			-- Was `simulation_switch' provided on command line?
		do
			Result := has_option (simulation_switch)
		end

	has_output_dir: BOOLEAN
			-- Was `output_dir_switch' provided on command line?
		do
			Result := has_switch (output_dir_switch)
		end

	has_configuration: BOOLEAN
			-- Was `config_switch' provided on command line?
		do
			Result := has_switch (config_switch)
		end

	configuration_filename: detachable STRING
		do
			if attached options_values_of_name (config_switch) as lst then
				if lst.count = 1 then
					Result := lst.first
				end
			end
		end

	output_directory: detachable STRING
		do
			if attached options_values_of_name (output_dir_switch) as lst then
				if lst.count = 1 then
					Result := lst.first
				end
			end
		end

	language: detachable STRING
		do
			if attached options_values_of_name (lang_switch) as lst then
				if lst.count = 1 then
					Result := lst.first
				end
			end
		end

end
