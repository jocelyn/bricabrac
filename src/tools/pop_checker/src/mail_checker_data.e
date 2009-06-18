note
	description: "Summary description for {MAIL_CHECKER_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MAIL_CHECKER_DATA

create
	make

feature {NONE} -- Initialization

	make (a_dir: like directory)
		require
			a_dir_attached: a_dir /= Void
			a_dir_exists: (create {DIRECTORY}.make (a_dir)).exists
		do
			set_directory (a_dir)
			create_directories
		end

	create_directories
		local
			dir: DIRECTORY
		do
			create dir.make (offline_directory)
			if not dir.exists then
				dir.create_dir
			end
		end

feature -- Access

	directory: STRING
			-- Directory containing the data
			-- abstract this later

	offline_directory: STRING

	profile_uuids: ARRAYED_LIST [STRING_8]
		local
			l_profiles: like profiles
		do
			l_profiles := profiles
			create Result.make (l_profiles.count)
			from
				l_profiles.start
			until
				l_profiles.after
			loop
				Result.force (l_profiles.key_for_iteration)
				l_profiles.forth
			end
		end

	profile_for (a_uuid: STRING_8): detachable POP3_PROFILE
			-- Profile with uuid starting with `a_uuid'	
		local
			p: detachable like profile
			st: like profiles
			l_uuid: STRING_8
			k: STRING_8
			nb: INTEGER
		do
			create l_uuid.make_from_string (a_uuid)
			l_uuid.to_upper
			p := profile (l_uuid)
			if p /= Void then
				Result := p
			else
				st := profiles
				from
					nb := 0
					st.start
				until
					st.after
				loop
					k := st.key_for_iteration.string
					k.keep_head (l_uuid.count)
					if k.is_case_insensitive_equal (l_uuid) then
						nb := nb + 1
						Result := st.item_for_iteration
					end
					st.forth
				end
				if nb > 1 then
					Result := Void
				end
			end
		end

	profile (a_uuid: STRING_8): detachable POP3_PROFILE
			-- Profile with uuid equal to `a_uuid'
		local
			st: like profiles
		do
			st := profiles
			if st.has_key (a_uuid) then
				Result := st.found_item
			end
		end

	profile_with_location (a_location: STRING): detachable POP3_PROFILE
		local
			l_uuids: like profile_uuids
			p: detachable like profile
			st: like profiles
		do
			l_uuids := profile_uuids
			if l_uuids.count > 0 then
				from
					l_uuids.start
				until
					l_uuids.after or Result /= Void
				loop
					p := profile (l_uuids.item)
					if p /= Void and then p.location ~ a_location then
						Result := p
					end
					l_uuids.forth
				end
			end
		end

	data (a_uuid: STRING_8): detachable POP3_MESSAGES_DATA
		require
			a_uuid_attached: a_uuid /= Void
		do
			Result ?= storable_from_file (data_edb_path (a_uuid))
		end

feature -- Element change: profiles	

	set_directory (s: like directory)
		local
			dn: DIRECTORY_NAME
		do
			directory := s
			create dn.make_from_string (s)
			dn.extend ("offline")
			offline_directory := dn.string
		end

	set_profile  (p: POP3_PROFILE)
		local
			l_profiles: like profiles
		do
			l_profiles := profiles
			l_profiles.force (p, p.uuid)
			save_profiles (l_profiles)
		end

	delete_profile (p: POP3_PROFILE)
		local
			l_profiles: like profiles
		do
			l_profiles := profiles
			l_profiles.remove (p.uuid)
			save_profiles (l_profiles)
		end

	save_profiles (a_profiles: like profiles)
		local
			f: RAW_FILE
		do
			create f.make (profiles_edb_path)
			if not f.exists or else f.is_writable then
				f.open_write
				f.independent_store (a_profiles)
				f.close
			else
				io.put_string ("ERROR: Can not save profiles list.")
			end
		end

feature -- Element change: data		

	set_data (a_data: POP3_MESSAGES_DATA)
		do
			save_data (a_data)
		end

	save_data (a_data: POP3_MESSAGES_DATA)
		local
			f: RAW_FILE
			d: DIRECTORY
		do
			create d.make (data_path (a_data.uuid))
			if not d.exists then
				d.create_dir
			end

			create f.make (data_edb_path (a_data.uuid))
			if not f.exists or else f.is_writable then
				f.open_write
				f.independent_store (a_data)
				f.close
			else
				io.put_string ("ERROR: Can not save data.")
			end
		end

feature {NONE} -- Implementation: Profiles

	profiles: HASH_TABLE [POP3_PROFILE, STRING_8]
		local
			st: detachable like profiles
			f: RAW_FILE
		do
			st ?= storable_from_file (profiles_edb_path)
			if st = Void then
				create st.make (100)
				st.compare_objects
				save_profiles (st)
			end
			Result := st
		end

	profiles_edb_path: STRING_8
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (directory)
			fn.set_file_name (profiles_edb_filename)
			Result := fn.string
		end

	profiles_edb_filename: STRING_8 = "profiles.edb"

feature {NONE} -- Implementation: Data	

	data_path (a_uuid: STRING_8): STRING_8
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (offline_directory)
			fn.extend (a_uuid)
			Result := fn.string
		end

	data_edb_path (a_uuid: STRING_8): STRING_8
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (data_path (a_uuid))
			fn.set_file_name (data_edb_filename)
			Result := fn.string
		end

	data_edb_filename: STRING_8 = "data.edb"

feature {NONE} -- Implementation: Profiles	

	storable_from_file (fn: STRING): detachable ANY
		local
			f: detachable RAW_FILE
			retried: BOOLEAN
		do
			if not retried then
				create f.make (fn)
				if f.exists and then f.is_readable then
					f.open_read
					Result ?= f.retrieved
					f.close
				end
			else
				if f /= Void and then f.is_open_read then
					f.close
				end
			end
		rescue
			retried := True
			retry
		end

invariant
	directory_attached: directory /= Void

end
