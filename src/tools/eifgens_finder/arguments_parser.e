note
	description: "[
		Used to parser command-line arguments.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision $"

class
	ARGUMENTS_PARSER

inherit
	ARGUMENT_MULTI_PARSER
		rename
			make as make_multi_parser
		redefine
			switch_groups
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize parser
		do
			make_multi_parser (False, False)
			set_is_using_separated_switch_values (True)
			set_is_usage_displayed_on_error (False)
			set_non_switched_argument_validator (create {ARGUMENTS_FOLDER_VALIDATOR})
			is_logo_information_suppressed := True
			is_allowing_non_switched_arguments := True
		end

feature -- Access

	folders: LINEAR [STRING]
			-- List of commands
		require
			is_successful: is_successful
		once
			Result := values
		ensure
			result_attached: Result /= Void
			not_result_is_empty: not Result.is_empty
		end

	verbose_mode: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (verbose_switch)
		end

	simulation_mode: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (simulating_switch)
		end

	interactive_mode: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (interactive_switch)
		end

	removal_mode: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (remove_switch)
		end

	removal_at_end_mode: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (remove_at_end_switch)
		end

	excludes_standard_folders: BOOLEAN
		require
			is_successful: is_successful
		once
			Result := has_option (std_exclusions_switch)
		end

	excluded_folders: LIST [STRING]
		require
			is_successful: is_successful
		once
			Result := options_values_of_name (exclude_switch)
		end

feature {NONE} -- Usage

	name: STRING = "EIFGENs finder (and remover) Utility"
			-- <Precursor>

	version: STRING
			-- <Precursor>
		once
			Result := "0.9"
		end

	non_switched_argument_description: STRING = "Folders to scan."
			-- <Precursor>

	non_switched_argument_name: STRING = "folder"
			-- <Precursor>

	non_switched_argument_type: STRING = "A folder"
			-- <Precursor>

	switches: ARRAYED_LIST [ARGUMENT_SWITCH]
			-- <Precursor>
		once
			create Result.make (7)
			Result.extend (create {ARGUMENT_SWITCH}.make (verbose_switch, "Display verbose messages.", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (interactive_switch, "Interactive mode.", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (remove_switch, "remove EIFGENs folder.", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (remove_at_end_switch, "process removal after scanning is done.", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (simulating_switch, "simulation (no removal).", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (std_exclusions_switch, "excludes standard excluded folder (.svn, .git, ..)", True, False))
			Result.extend (create {ARGUMENT_SWITCH}.make (exclude_switch, "exclude folder from scanning", True, True))
		end

	switch_groups: ARRAYED_LIST [ARGUMENT_GROUP]
			-- Valid switch grouping
		once
			create Result.make (2)
			Result.extend (create {ARGUMENT_GROUP}.make (<<
						switch_of_name (verbose_switch),
						switch_of_name (interactive_switch),
						switch_of_name (remove_switch),
						switch_of_name (remove_at_end_switch),
						switch_of_name (simulating_switch),
						switch_of_name (std_exclusions_switch),
						switch_of_name (exclude_switch)
					>>, True)
				)
		end

feature {NONE} -- Switch names

	verbose_switch: STRING = "v|verbose"
	interactive_switch: STRING = "i|interactive"
	remove_switch: STRING = "r|remove"
	remove_at_end_switch: STRING = "e|remove-at-end"
	simulating_switch: STRING = "n"
	std_exclusions_switch: STRING = "X|exclude-std"
	exclude_switch: STRING = "x|exclude"

;note
	copyright:	"Copyright (c) 1984-2009, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
