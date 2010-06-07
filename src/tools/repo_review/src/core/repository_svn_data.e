note
	description: "Summary description for {REPOSITORY_SVN_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REPOSITORY_SVN_DATA

inherit
	REPOSITORY_DATA
		redefine
			repository
		end

create
	make

feature -- Access

	logs: detachable HASH_TABLE [SVN_REVISION_INFO, INTEGER]

	get_logs (a_fetch: BOOLEAN)
		local
			l_head_rev: INTEGER
			l_last_fetched_rev: INTEGER
			l_repo_logs: like repository.logs
			l_logs: like logs
			d: DIRECTORY
			r: INTEGER
		do
			l_logs := logs
			if l_logs = Void then
				create l_logs.make (100)
				logs := l_logs
			end
			create d.make (data_folder_name)
			if d.exists then
				d.open_read
				from
					d.start
					d.readentry
				until
					d.lastentry = Void
				loop
					if attached d.lastentry as s and then s.is_integer then
						r := s.to_integer
						l_last_fetched_rev := l_last_fetched_rev.max (r)
						if not l_logs.has (r) and attached loaded_log (s.to_integer) as e then
							l_logs.put (e, r)
						end
					end
					d.readentry
				end
				d.close
			end
			if a_fetch then
				if attached repository.info as repo_info then
					l_head_rev := repo_info.last_changed_rev
					if l_last_fetched_rev > 0 then
						l_repo_logs := repository.logs (True, l_last_fetched_rev, l_head_rev, 10)
					else
						l_repo_logs := repository.logs (True, 0, 0, 100)
					end
					if l_repo_logs /= Void then
						from
							l_repo_logs.start
						until
							l_repo_logs.after
						loop
							if attached l_repo_logs.item as e then
								r := e.revision
								if l_logs.has (r) then
									l_logs.force (e, r)
								else
									l_logs.put (e, r)
								end
								store_log (e)
								check loaded_log (r) ~ e end
							end
							l_repo_logs.forth
						end
					end
				end
			end
		end

feature {NONE} -- Implementation

	repository: REPOSITORY_SVN

	data_folder_name: STRING
		do
			Result := "svn_logs_" + uuid.out + ".db"
		end

	last_stored_rev: INTEGER
		local
			d: DIRECTORY
		do
			create d.make (data_folder_name)
			if d.exists then
				d.open_read
				from
					d.start
					d.readentry
				until
					d.lastentry = Void
				loop
					if attached d.lastentry as s and then s.is_integer then
						Result := Result.max (s.to_integer)
					end
					d.readentry
				end
				d.close
			end
		end

	loaded_log (r: INTEGER): detachable SVN_REVISION_INFO
		local
			fn: FILE_NAME
			f: RAW_FILE
			l_line: STRING
			s: STRING
		do
			create fn.make_from_string (data_folder_name)
			fn.set_file_name (r.out)
			create f.make (fn)
			if f.exists and then f.is_readable then
				f.open_read
				from
					f.start
					create Result.make (r)
				until
					f.exhausted or Result = Void
				loop
					f.read_line
					l_line := f.last_string
					if l_line.starts_with ("revision=") then
						l_line.remove_head (9)
						if l_line.is_integer and then l_line.to_integer /= r then
							Result := Void
						end
					elseif l_line.starts_with ("date=") then
						l_line.remove_head (5)
						Result.set_date (l_line.string)
					elseif l_line.starts_with ("author=") then
						l_line.remove_head (7)
						Result.set_author (l_line.string)
					elseif l_line.starts_with ("parent=") then
--						l_line.remove_head (7)
					elseif l_line.starts_with ("path[]=") then
						l_line.remove_head (7)
						Result.add_path (l_line.string, "", "")
					elseif l_line.starts_with ("message=") then
						l_line.remove_head (8)
						Result.set_log_message (l_line.string)
					end
				end
				f.close
			end
		end

	store_log (r: SVN_REVISION_INFO)
		local
			fn: FILE_NAME
			d: DIRECTORY
			f: RAW_FILE
		do
			create d.make (data_folder_name)
			if not d.exists then
				if d.name.has (operating_environment.directory_separator) then
					d.recursive_create_dir
				else
					d.create_dir
				end
				create fn.make_from_string (d.name)
				fn.set_file_name ("info.txt")
				create f.make (fn)
				if not f.exists then
					f.create_read_write
					f.put_string ("location=" + repository.location + "%N")
					f.close
				end
			end
			create fn.make_from_string (d.name)
			fn.set_file_name (r.revision.out)
			create f.make (fn)
			if not f.exists then
				f.create_read_write
				f.put_string ("revision=" + r.revision.out + "%N")
				f.put_string ("date=" + r.date + "%N")
				f.put_string ("author=" + r.author + "%N")
				f.put_string ("parent=" + r.common_parent_path + "%N")
				if attached r.paths as l_paths and then not l_paths.is_empty then
					from
						l_paths.start
					until
						l_paths.after
					loop
						f.put_string ("path[]=" + l_paths.item.path + "%N")
						l_paths.forth
					end
				end
				f.put_string ("message=" + r.log_message + "%N")
				f.close
				print ("Log for rev#" + r.revision.out + " stored%N")
			else
				print ("Log for rev#" + r.revision.out + " already fetched%N")
			end
		end

end
