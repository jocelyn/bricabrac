note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	EIFGENS_FINDER

inherit
	EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		local
			args: ARGUMENTS_PARSER
			cwd: STRING
			d: STRING
			cleaning, interactive, simulating, verbose: BOOLEAN
		do
			create args.make
			args.execute (agent start (args))
		end

	start (args: ARGUMENTS_PARSER) is
		require
			args_attached: args /= Void
			args_successful: args.is_successful
		local
			cwd: STRING
			d: STRING
			cleaning, interactive, simulating, verbose: BOOLEAN
			l_folders: LINEAR [STRING]
		do
			cwd := current_working_directory

			if args.removal_at_end_mode then
				create eifgens_list.make (100)
			end
			cleaning := args.removal_mode
			interactive := args.interactive_mode
			simulating := args.simulation_mode
			verbose := args.verbose_mode
			if args.excludes_standard_folders then
				create excludes.make (10)
				excludes.compare_objects
				excludes.extend (".svn")
				excludes.extend (".git")
				excludes.extend ("CVS")
			end
			l_folders := args.folders
			if l_folders.is_empty then
				process (cwd, cleaning, interactive, verbose, simulating)
			else
				from
					l_folders.start
				until
					l_folders.after
				loop
					process (l_folders.item, cleaning, interactive, verbose, simulating)
					l_folders.forth
				end
			end
			if attached eifgens_list as lst then
				from
					lst.start
				until
					lst.after
				loop
					d := lst.item
					print ("+ " + d + "%N")
					if cleaning then
						remove_directory (d, interactive, simulating)
					end
					lst.forth
				end
			end
		end

	process (a_dir: STRING; a_clean: BOOLEAN; a_interactive: BOOLEAN; a_verbose: BOOLEAN; a_simulation: BOOLEAN)
		local
			dn: DIRECTORY_NAME
			dir: detachable DIRECTORY
			d: STRING
			nodes: LIST [STRING]
			excluded: BOOLEAN
		do
			dir := tmp_dir
			if dir = Void then
				create dir.make (a_dir)
				tmp_dir := dir
			else
				dir.make (a_dir)
			end
			if dir.exists then
				if a_verbose then
					print ("- " + a_dir + "%N")
				end
				nodes := dir.linear_representation
				dir := Void
				if not nodes.is_empty then
					from
						nodes.start
					until
						nodes.after
					loop
						d := nodes.item

							-- Excludes relative current dir, or relative parent dir
						excluded := (d.count = 1 and then d.item (1) = '.') or else	(d.count = 2 and then d.item (1) = '.' and then d.item (2) = '.')
						if not excluded and attached excludes as xlst then
							excluded := xlst.has (d)
						end
						if not excluded then
							create dn.make_from_string (a_dir)
							dn.extend (d)

							if d ~ "EIFGENs" then
								if attached eifgens_list as lst then
									if a_verbose then
										print ("+ " + dn + "%N")
									end
									lst.extend (dn)
								else
									print ("+ " + dn + "%N")
									if a_clean then
										remove_directory (dn, a_interactive, a_simulation)
									end
								end
							else
								process (dn, a_clean, a_interactive, a_verbose, a_simulation)
							end
						end
						nodes.forth
					end
				end
			end
		end

	tmp_dir: detachable DIRECTORY

	eifgens_list: detachable ARRAYED_LIST [STRING]

	excludes: detachable ARRAYED_LIST [STRING]

	remove_directory (a_dir: STRING; a_interactive: BOOLEAN; a_simulation: BOOLEAN)
		local
			dir: like tmp_dir
			ok: BOOLEAN
			s: STRING
		do
			dir := tmp_dir
			if dir = Void then
				create dir.make (a_dir)
			else
				dir.make (a_dir)
			end
			if a_simulation then
				ok := False
				print ("  - removal simulation. %N")
			else
				if a_interactive then
					io.put_string ("  Do you want to remove this directory (y|N) ?")
					io.read_line
					s := io.last_string
					s.to_lower
					s.left_adjust
					s.right_adjust
					ok := s.count = 1 and then s.item (1) = 'y'
				else
					ok := True
				end
			end
			if ok then
				if not a_simulation then
					dir.recursive_delete
				end
				print ("  - removed. %N")
			end
		end

feature -- Status

feature -- Access

feature -- Change

feature {NONE} -- Implementation

invariant
--	invariant_clause: True

end
