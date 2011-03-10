note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	EXIFTOOL

inherit
	EXIFTOOL_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			args_p: EXIFTOOL_ARGUMENT_PARSER
		do
			create args_p.make (False, False)
			args_p.execute (agent launch (args_p))
		end

	launch (a_args: EXIFTOOL_ARGUMENT_PARSER)
		require
			a_args_successful: a_args.is_successful
		local
			cfg: detachable EXIFTOOL_RENAMING_CONFIGURATION
			cfg_fn: detachable STRING
		do
			if a_args.has_configuration then
				cfg_fn := a_args.configuration_filename
			end
			if cfg_fn /= Void then
				cfg := file_to_cfg (cfg_fn)
			end
			if cfg = Void then
				cfg := default_cfg
				if cfg_fn /= Void then
					cfg_to_file (cfg, cfg_fn)
				end
			end
			if a_args.has_simulation then
				cfg.set_is_simulation (True)
			end
			if a_args.has_output_dir and then attached a_args.output_directory as o then
				cfg.set_output_directory (o)
			end

			if attached a_args.values as l_sources then
				from
					l_sources.start
				until
					l_sources.after
				loop
					process (l_sources.item, cfg)
					l_sources.forth
				end
			end
		end

feature -- Config

	default_cfg: EXIFTOOL_RENAMING_CONFIGURATION
		do
			create Result.make
			Result.set_output_directory ("output")
			Result.set_lower_extension (True)
			Result.set_output_filename_template ("Y_m_d__H_i_s")
			Result.set_output_folder_template ("Y/m/Y-m-d")
			Result.set_is_simulation (False)
			Result.set_verbose_level (2)
			Result.set_remove_file (False)
		end

	string_to_cfg (s: STRING): like default_cfg
		local
			lines: LIST [STRING]
			p: INTEGER
			line, k,v: STRING
		do
			Result := default_cfg
			lines := s.split ('%N')
			from
				lines.start
			until
				lines.after
			loop
				line := lines.item
				if line.count > 1 then
					if line.item (1) = '#' then
						-- skip
					else
						p := line.index_of ('=', 1)
						if p > 0 then
							k := line.substring (1, p - 1)
							k.left_adjust
							k.right_adjust
							k.to_lower
							v := line.substring (p + 1, line.count)
							v.left_adjust
							v.right_adjust
							if k.same_string (lower_extension_key) then
								if v.as_lower.same_string ("true") then
									Result.set_lower_extension (True)
								else
									Result.set_lower_extension (False)
								end
							elseif k.same_string (upper_extension_key) then
								if v.as_lower.same_string ("true") then
									Result.set_upper_extension (True)
								else
									Result.set_upper_extension (False)
								end
							elseif k.same_string (output_filename_template_key) then
								Result.set_output_filename_template (v)
							elseif k.same_string (output_folder_template_key) then
								Result.set_output_folder_template (v)
							elseif k.same_string (output_directory_key) then
								Result.set_output_directory (v)
							elseif k.same_string (simulation_key) then
								if v.as_lower.same_string ("false") then
									Result.set_is_simulation (False)
								else
									Result.set_is_simulation (True)
								end
							elseif k.same_string (verbose_level_key) then
								if v.is_integer then
									Result.set_verbose_level (v.to_integer)
								else
									print ("ERROR: invalid value [" + line + "]%N")
								end
							elseif k.same_string (remove_file_key) then
								if v.as_lower.same_string ("true") then
									Result.set_remove_file (True)
								else
									Result.set_remove_file (False)
								end
							else
								print ("ERROR: invalid key [" + line + "]%N")
							end
						else
							print ("ERROR: invalid entry [" + line + "]%N")
						end
					end
				end
				lines.forth
			end
		end

	cfg_to_string (cfg: like default_cfg): STRING
		do
			Result := ""

				--| lower_extension
			if not cfg.lower_extension then
				Result.append_character ('#')
			end
			Result.append_string (lower_extension_key)
			Result.append_character ('=')
			Result.append_boolean (cfg.lower_extension)
			Result.append_character ('%N')

				--| upper_extension
			if not cfg.upper_extension then
				Result.append_character ('#')
			end
			Result.append_string (upper_extension_key)
			Result.append_character ('=')
			Result.append_boolean (cfg.upper_extension)
			Result.append_character ('%N')

				--| output_directory
			if cfg.output_directory_is_default then
				Result.append_character ('#')
			end
			Result.append_string (output_directory_key)
			Result.append_character ('=')
			Result.append_string (cfg.output_directory)
			Result.append_character ('%N')

				--| output_filename_template
			Result.append_string (output_filename_template_key)
			Result.append_character ('=')
			Result.append_string (cfg.output_filename_template)
			Result.append_character ('%N')

				--| output_folder_template
			Result.append_string (output_folder_template_key)
			Result.append_character ('=')
			Result.append_string (cfg.output_folder_template)
			Result.append_character ('%N')

				--| verbose_level
			Result.append_string (verbose_level_key)
			Result.append_character ('=')
			Result.append_integer (cfg.verbose_level)
			Result.append_character ('%N')

				--| is_simulation
			if not cfg.is_simulation then
				Result.append_character ('#')
			end
			Result.append_string (simulation_key)
			Result.append_character ('=')
			Result.append_boolean (cfg.is_simulation)
			Result.append_character ('%N')

				--| remove_file
			if not cfg.remove_file then
				Result.append_character ('#')
			end
			Result.append_string (remove_file_key)
			Result.append_character ('=')
			Result.append_boolean (False)
			Result.append_character ('%N')
		end

	cfg_to_file (a_cfg: like default_cfg; a_filename: STRING)
		local
			f: RAW_FILE
		do
			create f.make (a_filename)
			if not f.exists or else f.is_writable then
				f.open_write
				f.put_string (cfg_to_string (a_cfg))
				f.close
			end
		end

	file_to_cfg (a_filename: STRING): detachable like default_cfg
		local
			f: RAW_FILE
			s: STRING
		do
			create f.make (a_filename)
			if f.exists and then f.is_readable then
				f.open_read
				f.read_stream (2 * f.count)
				s := f.last_string
				f.close
				Result := string_to_cfg (s)
			end
		end

	output_directory_key: STRING = "output_directory"
	lower_extension_key: STRING = "lower_extension"
    upper_extension_key: STRING = "upper_extension"
    output_filename_template_key: STRING = "output_filename_template"
    output_folder_template_key: STRING = "output_folder_template"
    verbose_level_key: STRING = "verbose_level"
    simulation_key: STRING = "simulation"
    remove_file_key: STRING = "remove_file"

feature -- Basic operations

	log (a_cfg: detachable like default_cfg; a_level: INTEGER; mesg: STRING)
		local
			f: RAW_FILE
		do
			if a_cfg = Void or else a_cfg.is_verbose (a_level) then
				print (mesg)
				if a_cfg /= Void then
					create f.make_open_append (a_cfg.output_directory + operating_environment.directory_separator.out + "exiftool.logs")
					f.put_string (mesg)
					f.close
				end
			end
		end

	process (dir: STRING; a_cfg: like default_cfg)
		local
			target_dn: STRING;
			keep_same_filename: BOOLEAN

			data_lst: detachable HASH_TABLE [like exiftool_data, STRING] -- data indexed by filename
			d: DIRECTORY
			p: INTEGER

			dt: detachable DATE_TIME
			fn: detachable STRING
			ext: detachable STRING

			target_filename: detachable STRING
			new_fn: detachable STRING
			new_dn: detachable STRING
			err_msg: detachable STRING

			b: BOOLEAN
		do
			target_dn := a_cfg.output_directory
			keep_same_filename := a_cfg.output_filename_template /= Void
			create d.make (dir)

			log (a_cfg, 1, "Retrieving list of files%N")

			if False and attached file_list (d.name) as file_lst then
				log (a_cfg, 1, "Retrieving EXIF data from files ...%N")

				from
					create data_lst.make (file_lst.count)
					file_lst.start
				until
					file_lst.after
				loop
					log (a_cfg, 2, "Retrieving EXIF data from %""+ file_lst.item +"%" ...%N")
					data_lst.extend (exiftool_data (file_lst.item), file_lst.item)
					debug ("exiftool")
						if attached data_lst.item (file_lst.item) as l_data then
							print (file_lst.item + "%N")
							from
								l_data.start
							until
								l_data.after
							loop
								print ("  - " + l_data.key_for_iteration + "=%"" + l_data.item_for_iteration + "%"%N")
								l_data.forth
							end
						end
					end
					file_lst.forth
				end
			else
				data_lst := exiftool_recursive_data (d.name)
			end

			if data_lst /= Void then
				from
					data_lst.start
				until
					data_lst.after
				loop
					err_msg := Void
					if attached data_lst.item_for_iteration as l_data then
						target_filename := Void
						new_fn := Void
						new_dn := Void
						if l_data.has (xml_name ("exif-version")) or else l_data.has (xml_name ("date-time-original-video")) then
							dt := Void
							fn := Void
							ext := Void
							if
								attached l_data.has_key (xml_name ("date-time-original")) and then
								attached l_data.found_item as l_exif_datetime
							then
								dt := exif_date_time (l_exif_datetime)
							elseif
								attached l_data.has_key (xml_name ("date-time-original-video")) and then
								attached l_data.found_item as l_video_datetime
							then
								dt := exif_date_time (l_video_datetime)
							end
							if
								attached l_data.has_key (xml_name ("filename")) and then
								attached l_data.found_item as l_system_filename
							then
								fn := l_system_filename
							end
							if fn /= Void then
								p := fn.last_index_of ('.', fn.count)
								if p > 0 then
									ext := fn.substring (p + 1, fn.count)
								end
							end
							if dt /= Void then
								create new_fn.make_empty
								if attached a_cfg.output_filename_template as l_output_filename_template then
									new_fn.append_string_general (formatted_date_time(dt, l_output_filename_template))
									if ext /= Void then
										new_fn.extend ('.')
										if a_cfg.lower_extension then
											new_fn.append (ext.as_lower)
										elseif a_cfg.upper_extension then
											new_fn.append (ext.as_upper)
										else
											new_fn.append (ext)
										end
									end
								elseif fn /= Void then
									new_fn.append_string_general (fn)
								end
								if new_fn.item (1) = '/' then
									new_fn.remove_head (1)
								end
								if attached a_cfg.prefix_name as l_prefix_name then
									new_fn.prepend_string_general (l_prefix_name)
								end
								if new_fn.item (1) = '/' then
									new_fn.remove_head (1)
								end

								create new_dn.make_from_string (a_cfg.output_directory)
								if attached a_cfg.output_folder_template as l_output_folder_template then
									new_dn.extend (Operating_environment.directory_separator)
									new_dn.append_string_general (formatted_date_time(dt, l_output_folder_template))
								end
								if new_dn.item (new_dn.count) = '/' then
									new_dn.remove_tail (1)
								end
								convert_to_platform_file_system (new_dn)
							else
								err_msg := "ERROR: unable to retrieve date"
							end
						else
							err_msg := "ERROR: unable to retrieve exif version"
						end

						if err_msg /= Void then
							log (a_cfg, 0, "File: %"" + data_lst.key_for_iteration + "%" : " + err_msg + "%N")
						elseif new_dn /= Void and new_fn /= Void then
							create target_filename.make_from_string (new_dn)
							target_filename.extend (Operating_environment.directory_separator)
							target_filename.append (new_fn)

							if data_lst.key_for_iteration.same_string (target_filename) then
								log (a_cfg, 2, "File: %"" + data_lst.key_for_iteration + "%" : ok %N")
							else
								log (a_cfg, 0, "File: %"" + data_lst.key_for_iteration + "%" : move to " +
									"%"" + target_filename + "%"" + "%N")
								if not a_cfg.is_simulation then
									safe_mkdir (new_dn, a_cfg)
									if a_cfg.remove_file then
										b := safe_move (data_lst.key_for_iteration, target_filename, a_cfg)
									else
										b := safe_copy (data_lst.key_for_iteration, target_filename, a_cfg)
									end
								end
							end
						end
					end
					data_lst.forth
				end
			end
		end

	safe_mkdir (dn: STRING; a_cfg: like default_cfg)
		local
			d: DIRECTORY
		do
			create d.make (dn)
			if not d.exists then
				log (a_cfg, 3, "Creating directory %"" + dn + "%"%N")
				if not a_cfg.is_simulation then
					d.recursive_create_dir
				end
			end
		end

	safe_move (fn: STRING; target_fn: STRING; a_cfg: like default_cfg): BOOLEAN
		local
			f_origin: RAW_FILE
		do
			Result := safe_copy (fn, target_fn, a_cfg)
			if Result then
				log (a_cfg, 3, "Delete %"" + fn + "%"%N")
				if fn.same_string (target_fn) then
					log (a_cfg, 1, "ERROR: same file !!!%N")
					Result := False
				else
					if not a_cfg.is_simulation then
						create f_origin.make (fn)
						if f_origin.exists then
							f_origin.delete
						end
					end
					Result := True
				end
			end
		end

	safe_copy (fn: STRING; target_fn: STRING; a_cfg: like default_cfg): BOOLEAN
		local
			f_origin,f_target: RAW_FILE
			d: INTEGER
		do
			log (a_cfg, 3, "Copy %"" + fn + "%" to %"" + target_fn + "%"%N")
			if fn.same_string (target_fn) then
				log (a_cfg, 1, "ERROR: same file !!!%N")
				Result := False
			else
				create f_origin.make (fn)
				if f_origin.exists then
					f_origin.open_read
					d := f_origin.date
					create f_target.make (target_fn)
					if f_target.exists then
						log (a_cfg, 1, "WARNING: file %""+ target_fn +"%" already exists -> Renaming !!!%N")
						create f_target.make (smart_duplicated_target_file_name (target_fn))
					end
					if f_target.exists then
						log (a_cfg, 1, "ERROR: file %""+ target_fn +"%" already exists !!!%N")
						Result := False
					else
						if not a_cfg.is_simulation then
							f_target.create_read_write

							f_origin.copy_to (f_target)

							f_target.set_date (d)
							f_target.close
						end
						Result := True
					end
					f_origin.close
				end
			end
		end

	smart_duplicated_target_file_name (a_fn: STRING): STRING
		local
			n: INTEGER
			nfn: STRING
			f: RAW_FILE
		do
			from
				create f.make (a_fn)
				n := 1
			until
				not f.exists or n > 10
			loop
				f.make (a_fn + "-" + n.out)
			end
			Result := f.name
		end

	file_list (dn: STRING): detachable ARRAYED_LIST [STRING]
		local
			d: DIRECTORY
			n: detachable STRING
			fn: FILE_NAME
			f: RAW_FILE
		do
			create d.make (dn)
			if d.exists and then d.is_readable then
				d.open_read
				from
					create fn.make_temporary_name
					create f.make (fn.string)
					create Result.make (d.count)

					d.start
					d.readentry
				until
					d.lastentry = Void
				loop
					n := d.lastentry
					if n = Void or else n.count = 0 or else n.item (1) = '.' then
						-- skip
					else
						fn.wipe_out
						fn.set_directory (dn)
						fn.set_file_name (n)
						f.make (fn.string)
						if f.exists then
							if f.is_directory then
								if
									attached file_list (fn.string) as sub_list and then
									sub_list.count > 0
								then
									Result.append (sub_list)
								end
							elseif f.is_readable then
								Result.force (fn.string)
							end
						end
					end
					d.readentry
				end
				d.close
			end
		end

feature {NONE} -- Implementation

	exif_date_time (a_date: STRING): detachable DATE_TIME
		local
			ymd: detachable STRING
			his: detachable STRING
			y,m,d: INTEGER
			h,i,s: INTEGER
			p: INTEGER
			lst: LIST [STRING]
			t: STRING
			err: BOOLEAN
		do
			if a_date.count > 0 then
				p := a_date.index_of (' ', 1)
				if p > 0 then
					ymd := a_date.substring (1, p - 1)
					his := a_date.substring (p + 1, a_date.count)
				else
					ymd := a_date.substring (1, a_date.count)
					his := Void
				end
				if ymd /= Void then
					lst := ymd.split (':')
					if lst.count = 3 then
						lst.start
						t := lst.item
						if t.is_integer then
							y := t.to_integer
							lst.forth
							t := lst.item
							if t.is_integer then
								m := t.to_integer
								lst.forth
								t := lst.item
								if t.is_integer then
									d := t.to_integer
								else
									err := True
								end
							else
								err := True
							end
						else
							err := True
						end
					else
						err := True
					end

					if his /= Void then
						lst := his.split (':')
						if lst.count = 3 then
							lst.start
							t := lst.item
							if t.is_integer then
								h := t.to_integer
								lst.forth
								t := lst.item
								if t.is_integer then
									i := t.to_integer
									lst.forth
									t := lst.item
									if t.is_integer then
										s := t.to_integer
									else
										err := True
									end
								else
									err := True
								end
							else
								err := True
							end
						else
							err := True
						end
					end
				else
					err := True
				end
				if not err then
					create Result.make (y, m, d, h, i, s)
				end
			end
		end

	exiftool_recursive_data (a_dirname: STRING): detachable HASH_TABLE [like exiftool_data, STRING]
		local
			parser: XML_LITE_CUSTOM_PARSER
			tree: XML_CALLBACKS_NULL_FILTER_DOCUMENT
			n,v: STRING
			l_data: like exiftool_data
			l_path: detachable STRING
		do
			if attached exiftool_xml_output (a_dirname, <<"-r">>) as xml then
				create parser.make
				create tree.make_null
				parser.set_callbacks (tree)
				parser.parse_from_string (xml)
				if not parser.error_occurred and then attached tree.document as doc then
					if attached doc.root_element.elements_by_name ("rdf:Description") as rdf_desc_list then
						from
							create Result.make (rdf_desc_list.count)
							rdf_desc_list.start
						until
							rdf_desc_list.after
						loop
							if attached {XML_ELEMENT} rdf_desc_list.item as rdf_desc then
--								if attached rdf_desc.attribute_by_name ("rdf:about") as att then
								if attached rdf_desc.attribute_by_name ("about") as att then
									l_path := att.value.string
									convert_to_platform_file_system (l_path)
									l_data := exiftool_data_from_rdf_description (rdf_desc)
									if l_data /= Void then
										Result.force (l_data, l_path)
									end
								else
									log (Void, 0, "ERROR...%N")
								end
							end
							rdf_desc_list.forth
						end
					end
				end
			end
		end

	exiftool_data (a_filename: STRING): detachable HASH_TABLE [STRING, STRING]
		local
			parser: XML_LITE_CUSTOM_PARSER
			tree: XML_CALLBACKS_NULL_FILTER_DOCUMENT
			n,v: STRING
		do
			if attached exiftool_xml_output (a_filename, Void) as xml then
				create parser.make
				create tree.make_null
				parser.set_callbacks (tree)
				parser.parse_from_string (xml)
				if not parser.error_occurred and then attached tree.document as doc then
					if attached doc.root_element.element_by_name ("rdf:Description") as rdf_desc then
						Result := exiftool_data_from_rdf_description (rdf_desc)
					end
				end
			end
		end

	exiftool_data_from_rdf_description (rdf_desc: XML_ELEMENT): like exiftool_data
		local
			n,v: STRING
		do
			if attached rdf_desc.elements as elts and then elts.count > 0 then
				from
					create Result.make (elts.count)
					elts.start
				until
					elts.after
				loop
					n := elts.item.name
					create v.make_empty
					if attached elts.item.contents as l_contents then
						from
							l_contents.start
						until
							l_contents.after
						loop
							v.append_string (l_contents.item.content)
							l_contents.forth
						end
					end
					Result.force (v, n)
					elts.forth
				end
			end
		end

	exiftool_xml_output (a_filename: STRING; params: detachable ARRAY [STRING]): detachable STRING
		local
			pfact: PROCESS_FACTORY
			p: PROCESS
			args: ARRAYED_LIST [STRING]
			buffer: STRING
			i: INTEGER
			params_cursor: like {ARRAY [STRING]}.new_cursor
		do
			create pfact
			if params /= Void then
				create args.make (params.count + 2)
				params_cursor := params.new_cursor
				from
					params_cursor.start
				until
					params_cursor.after
				loop
					args.force (command_line_option_name (params_cursor.item))
					params_cursor.forth
				end
			else
				create args.make (2)
			end
			args.compare_objects
			args.force ("-X")
			args.force ("-fast")
			args.force ("-fast2")
--			args.force ("-b")
			args.force (a_filename)

			p := pfact.process_launcher (executable_filename, args, Void)
			p.disable_terminal_control
			p.set_detached_console (True)
			p.set_separate_console (True)
			p.set_hidden (True)
			create buffer.make (100)
			p.redirect_output_to_agent (agent process_output_handler (?, buffer))
--			p.redirect_error_to_agent (agent process_output_handler (?, buffer))
			p.launch
			if args.has ("-r") then
				p.wait_for_exit
				Result := buffer
			else
				p.wait_for_exit_with_timeout (3_000) -- 3 seconds
				if p.has_exited then
					Result := buffer
				end
			end
		end

	process_output_handler (s: STRING; buf: STRING)
		do
			buf.append (s)
		end

	xml_name (s: STRING): STRING
		do
			if
				xml_mapping_names.has_key (s) and then
				attached xml_mapping_names.found_item as i
			then
				Result := i
			else
				Result := s.string
			end
		end

	command_line_option_name (s: STRING): STRING
		do
			if
				command_line_mapping_option_names.has_key (s) and then
				attached command_line_mapping_option_names.found_item as i
			then
				Result := i
			else
				Result := s.string
			end
		end

	xml_mapping_names: HASH_TABLE [STRING, STRING]
		once
			create Result.make (20)
			Result.compare_objects
			Result.force ("System:FileName","filename")
			Result.force ("System:Directory","directory")
			Result.force ("System:FileSize","filesize")
			Result.force ("File:FilteType","filetype")
			Result.force ("File:MIMEType","mimetype")
			Result.force ("File:ImageWidth","image-width")
			Result.force ("File:ImageHeight","image-height")
			Result.force ("ExifIFD:ExifVersion","exif-version")
			Result.force ("ExifIFD:DateTimeOriginal","date-time-original")
			Result.force ("RIFF:DateTimeOriginal","date-time-original-video")
			Result.force ("ExifIFD:CreateDate","create-date")
		end

	command_line_mapping_option_names: HASH_TABLE [STRING, STRING]
		once
			create Result.make (2)
			Result.compare_objects
			Result.force ("-filename","filename")
			Result.force ("-DateTimeOriginal","date_time_original")
			Result.force ("ExifIFD:DateTimeOriginal","date_time_original")
		end

	convert_to_platform_file_system (s: STRING)
		do
			if Operating_environment.directory_separator /= '/' then
				s.replace_substring_all ("/", Operating_environment.directory_separator.out)
			end
		end

	formatted_date_time (a_date_time: DATE_TIME; a_date_time_format: STRING): STRING_GENERAL
		local
			y,m,d,h,mn,sec: INTEGER
			s32: STRING_32
			s: STRING
			c: CHARACTER_32
			i: INTEGER
		do
			create s32.make (a_date_time_format.count)
			from
				i := 1
				m := a_date_time.month
				y := a_date_time.year
				d := a_date_time.day
				h := a_date_time.hour
				mn := a_date_time.minute
				sec := a_date_time.second
			until
				i > a_date_time_format.count
			loop
				c := a_date_time_format[i]
				inspect c
				when 'Y' then s32.append_integer (y)
				when 'y' then
					s := y.out
					s.keep_tail (2)
					s32.append_string (s)
				when 'm' then
					if m < 10 then
						s32.append_integer (0)
					end
					s32.append_integer (m)
				when 'n' then s32.append_integer (m)
				when 'M' then
					s := a_date_time.months_text [m].string
					s.to_lower; s.put (s.item (1).as_upper, 1); s32.append_string (s)
				when 'F' then
					s := a_date_time.long_months_text [m].string
					s.to_lower; s.put (s.item (1).as_upper, 1); s32.append_string (s)
				when 'D' then
					s := a_date_time.days_text [a_date_time.date.day_of_the_week].string
					s.to_lower; s.put (s.item (1).as_upper, 1); s32.append_string (s)
				when 'l' then
					s := a_date_time.long_days_text [a_date_time.date.day_of_the_week].string
					s.to_lower; s.put (s.item (1).as_upper, 1); s32.append_string (s)

				when 'd' then
					if d < 10 then
						s32.append_integer (0)
					end
					s32.append_integer (d)
				when 'j' then
					s32.append_integer (d)
--							when 'z' then s32.append_integer (a_date_time.date.*year)
				when 'a' then
					if h >= 12 then
						s32.append_character ('p'); s32.append_character ('m')
					else
						s32.append_character ('a'); s32.append_character ('m')
					end
				when 'A' then
					if h >= 12 then
						s32.append_character ('P'); s32.append_character ('M')
					else
						s32.append_character ('A'); s32.append_character ('M')
					end
				when 'g','h' then
					if h >= 12 then
						if c = 'h' and h - 12 < 10 then
							s32.append_integer (0)
						end
						s32.append_integer (h - 12)
					else
						if c = 'h' and h < 10 then
							s32.append_integer (0)
						end
						s32.append_integer (h)
					end
				when 'G', 'H' then
					if c = 'H' and h < 10 then
						s32.append_integer (0)
					end
					s32.append_integer (h)
				when 'i' then
					if mn < 10 then
						s32.append_integer (0)
					end
					s32.append_integer (mn)
				when 's' then
					if sec < 10 then
						s32.append_integer (0)
					end
					s32.append_integer (sec)
				when 'u' then
					s32.append_double (a_date_time.fine_second) -- CHECK result ...
				when 'w' then s32.append_integer (a_date_time.date.day_of_the_week - 1)
				when 'W' then s32.append_integer (a_date_time.date.week_of_year)
				when 'L' then
					if a_date_time.is_leap_year (y) then
						s32.append_integer (1)
					else
						s32.append_integer (0)
					end
				when '\' then
					if i < a_date_time_format.count then
						i := i + 1
						s32.append_character (a_date_time_format[i])
					else
						s32.append_character ('\')
					end
				else
					s32.append_character (c)
				end
				i := i + 1
			end
			Result := s32
		end

end
