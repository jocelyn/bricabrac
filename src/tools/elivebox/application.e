indexing
	description : "elivebox application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make is
			-- Run application.
		local
			requested_status, requested_easy_status: INTEGER
		do
			if argument_count > 0 then
				if argument_array.has ("on")  then
					requested_status := 1
				end
				if argument_array.has ("off")  then
					requested_status := -1
				end
				if argument_array.has ("wifi=on")  then
					requested_status := 1
				end
				if argument_array.has ("wifi=off") then
					requested_status := -1
				end
				if argument_array.has ("easy=on") then
					requested_easy_status := 1
				end
				if argument_array.has ("easy=off") then
					requested_easy_status := -1
				end
				site_login := separate_word_option_value ("-login")
				site_password := separate_word_option_value ("-password")
				site_domain := separate_word_option_value ("-domain")
			end

			get_parameters
--			print ("login    = " + site_login + "%N")
--			print ("password = " + site_password + "%N")
--			print ("domain   = " + site_domain + "%N")

			if curl.is_dynamic_library_exists then
				curl.global_init
				process_wifi_network (requested_status)
				process_easy_wifi (requested_easy_status)
				curl.global_cleanup
			else
				print ("Missing dll needed by curl%N")
			end
		end

	process_wifi_network (requested_status: INTEGER)
		local
			failed: BOOLEAN
			toggle_requested: BOOLEAN
			cfg: like wifi_config_for
			st: BOOLEAN
		do
			if {l_wifi_cfg: like wifi_config_for} wifi_config_for (site_login, site_password, site_domain) then
				cfg := l_wifi_cfg
				print ("Wifi network canal=" + l_wifi_cfg.canal + " wifikey=%"" + l_wifi_cfg.wifikey + "%"")
				if l_wifi_cfg.activated then
					print (" is ON%N")
				else
					print (" is OFF%N")
				end
				toggle_requested := (l_wifi_cfg.activated and requested_status = -1) or (not l_wifi_cfg.activated and requested_status = 1)
			else
				failed := True
				print ("Error: unable to get WiFi information.%N")
			end
			if not failed and cfg /= Void and toggle_requested then
				if requested_status = 1 then
					st := True
				else
					st := False
				end
				if {r: STRING} set_wifi_status_for (site_login, site_password, site_domain, cfg, st) then
					print ("Wifi network: change status -> " + r)
					io.put_new_line
				else
					failed := True
					print ("Wifi network-> No information on wifi 'toggle' operation")
					io.put_new_line
				end
				if {l_op_wifi_cfg: like wifi_config_for} wifi_config_for (site_login, site_password, site_domain) then
					print ("Wifi network canal=" + l_op_wifi_cfg.canal + " wifikey=%"" + l_op_wifi_cfg.wifikey + "%"")
					if l_op_wifi_cfg.activated then
						print (" is now ON%N")
					else
						print (" is now OFF%N")
					end
					failed := (l_op_wifi_cfg.activated and requested_status = -1) or (not l_op_wifi_cfg.activated and requested_status = 1)
				else
					failed := True
					print ("Wifi network: unable to get information%N")
				end
				if failed then
					print ("Wifi network: operation failed !!!%N")
				end
			end
		end

	process_easy_wifi (requested_easy_status: INTEGER)
		local
			failed, toggle_easy_requested: BOOLEAN
		do
			if {l_easy_wifi_details: like easy_wifi_details} easy_wifi_details_for (site_login, site_password, site_domain) then
				if l_easy_wifi_details.activated then
					print ("Easy Wifi %"" + l_easy_wifi_details.ssid + "%" is activated%N")
				else
					print ("Easy Wifi %"" + l_easy_wifi_details.ssid + "%" is deactivated%N")
				end
				toggle_easy_requested := (l_easy_wifi_details.activated and requested_easy_status = -1) or (not l_easy_wifi_details.activated and requested_easy_status = 1)
			else
				failed := True
				print ("Error: unable to get Easy WiFi information.%N")
			end

			if not failed and toggle_easy_requested then
				if {s: STRING} toggle_easy_wifi_for (site_login, site_password, site_domain) then
					print ("Change status -> " + s)
					io.put_new_line
				else
					failed := True
					print ("Easy Wifi -> No information on easy wifi 'toggle' operation")
					io.put_new_line
				end
				if {l_op_easy_wifi_details: like easy_wifi_details} easy_wifi_details_for (site_login, site_password, site_domain) then
					if l_op_easy_wifi_details.activated then
						print ("Easy Wifi %"" + l_op_easy_wifi_details.ssid + "%" is now activated%N")
					else
						print ("Easy Wifi %"" + l_op_easy_wifi_details.ssid + "%" is now deactivated%N")
					end
					failed := (l_op_easy_wifi_details.activated and requested_easy_status = -1) or (not l_op_easy_wifi_details.activated and requested_easy_status = 1)
				else
					failed := True
					print ("Easy Wifi: unable to get details%N")
				end
				if failed then
					print ("Easy Wifi: operation failed !!!%N")
				end
			end
		end

	get_parameters
		local
			ini_fn: STRING
			f: RAW_FILE
			vars: LINKED_LIST [like parameters_from_line]
			m: BOOLEAN
		do
			create ini_fn.make_from_string (argument (0))
			ini_fn.append_string (".cfg")
			debug
				print ("ini=" + ini_fn + "%N")
			end
			create f.make (ini_fn)
			create vars.make
			if f.exists and then f.is_readable then
				f.open_read
				from
					f.read_line
				until
					f.end_of_file or f.exhausted
				loop
					if {pars: like parameters_from_line} parameters_from_line (f.last_string) then
						vars.extend (pars)
						if site_login = Void and then pars.name.is_equal ("login") then
							site_login := pars.value
						elseif site_password = Void and then pars.name.is_equal ("password") then
							site_password := pars.value
						elseif site_domain = Void and then pars.name.is_equal ("domain") then
							site_domain := pars.value
						else
							print ("Unknown parameter: %"" + pars.name + "=" + pars.value + "%" %N")
						end
					end
					f.read_line
				end
				f.close
			else
				m := True
			end
			if site_login = Void then
				m := True
				site_login := question ("Enter admin username", Void)
				vars.extend (["login", site_login])
			end
			if site_password = Void then
				m := True
				site_password := question ("Enter admin password", Void)
				vars.extend (["password", site_password])
			end
			if site_domain = Void then
				m := True
				site_domain := question ("Enter livebox's domain", "192.168.1.1")
				vars.extend (["domain", site_domain])
			end
			if m and then vars.count > 0 then
				f.open_write
				from
					vars.start
				until
					vars.after
				loop
					f.put_string (parameters_to_line (vars.item))
					f.put_new_line
					vars.forth
				end
				f.close
			end
		end

	question (m: STRING; d: STRING): STRING
		local
			s: STRING
		do
			from
			until
				Result /= Void
			loop
				print (" - ")
				print (m)
				if d /= Void then
					print (" [" + d + "] ")
				end
				print (":")
				io.read_line
				s := io.last_string.twin
				s.left_adjust
				s.right_adjust
				if s.is_empty then
					s := d
				end
				if s /= Void and then not s.is_empty then
					Result := s
				end
			end
		end

	parameter_key (n: STRING): INTEGER
		local
			i: INTEGER
			u,l: INTEGER
		do
			l := 35
			u := 125
			from
				i := 1
			until
				i > n.count
			loop
				Result := Result + n.item_code (i)
				i := i + 1
			end
			Result := Result \\ (u - l)
		end

	crypted_parameter_value (n, v: STRING): STRING
		local
			i, k, c: INTEGER
			u,l: INTEGER
		do
			l := 35
			u := 125
			k := parameter_key (n)
			Result := v
			from
				create Result.make (v.count)
				i := v.count
			until
				i < 1
			loop
				c := l + ((v.item_code (i) + k + i - l) \\ (u - l))
				Result.append_code (c.as_natural_32)
				i := i - 1
			end
--			Result := v
		end

	uncrypted_parameter_value (n,cv: STRING): STRING
		local
			i, k, c: INTEGER
			u,l: INTEGER
		do
			l := 35
			u := 125
			k := parameter_key (n)
			Result := cv
			from
				create Result.make (cv.count)
				i := cv.count
			until
				i < 1
			loop
				c := cv.item_code (i) - k - (1 + cv.count - i)
				if c < l then
					c := c + u - l
				end
				Result.append_code (c.as_natural_32)
				i := i - 1
			end
		end

	parameters_to_line (pars: like parameters_from_line): STRING
		local
			n,v: STRING
		do
			create Result.make (10)
			n := pars.name
			v := pars.value
			Result.append_string (n)
			Result.append_character ('=')
			Result.append_string (crypted_parameter_value (n, v))
		end

	parameters_from_line (a_line: ?STRING): TUPLE [name: STRING; value: STRING]
		local
			p: INTEGER
			s: STRING
		do
			if a_line /= Void and then not a_line.is_empty then
				p := a_line.index_of ('=', 1)
				if p > 0 then
					create Result
					s := a_line.substring (1, p - 1)
					s.left_adjust
					s.right_adjust
					s.to_lower
					Result.name := s
					s := a_line.substring (p + 1, a_line.count)
					s.left_adjust
					s.right_adjust
					Result.value := uncrypted_parameter_value (Result.name, s)
				end
			end
		end

	wifi_config_for (a_login, a_password, a_domain: STRING): like wifi_config
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
		do
			l_url := "http://" + a_login + ":" + a_password + "@" + a_domain

			curl_handle := curl_easy.init
			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url + "/wifi.html")
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string.object_id)
			l_result := curl_easy.perform (curl_handle)
			curl_easy.cleanup (curl_handle)
			if not l_curl_string.is_empty then
				Result := wifi_config (l_curl_string.string)
			end
		end


	set_wifi_status_for (a_login, a_password, a_domain: STRING; a_config: like wifi_config; a_activated: BOOLEAN): STRING
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			s: STRING
			p,e: INTEGER
		do
			if a_config.activated /= a_activated then
				l_url := "http://" + a_login + ":" + a_password + "@" + a_domain
				l_url.append_string ("/wifiok.cgi?wifiChannel=" + a_config.canal + "&wifiKey63=" + a_config.wifikey + "&enblWifi=")
				if a_activated then
					l_url.append_string ("1")
				else
					l_url.append_string ("0")
				end

				curl_handle := curl_easy.init
				curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url)
				curl_easy.set_write_function (curl_handle)
				create l_curl_string.make_empty
				curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string.object_id)
				l_result := curl_easy.perform (curl_handle)
				curl_easy.cleanup (curl_handle)
				if not l_curl_string.is_empty then
					s := l_curl_string.string
					p := s.substring_index ("<form>", 1)
					if p > 0 then
						p := s.substring_index ("<b>", p + 1)
						if p > 0 then
							e := s.substring_index ("</b>", p + 1)
							if e > p then
								s := s.substring (p + 3, e - 1)
								p := s.index_of ('<', 1)
								if p > 0 then
									s := s.substring (1, p - 1)
									Result := s.twin
									Result.replace_substring_all ("&eacute;", "e")
								end
							end
						end
					end
				end
			end
		end


	easy_wifi_details_for (a_login, a_password, a_domain: STRING): like easy_wifi_details
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
		do
			l_url := "http://" + a_login + ":" + a_password + "@" + a_domain

			curl_handle := curl_easy.init
			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url + "/wireless.html")
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string.object_id)
			l_result := curl_easy.perform (curl_handle)
			curl_easy.cleanup (curl_handle)
			if not l_curl_string.is_empty then
				Result := easy_wifi_details (l_curl_string.string)
			end
		end

	toggle_easy_wifi_for (a_login, a_password, a_domain: STRING): STRING
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			s: STRING
			p,e: INTEGER
		do
			l_url := "http://" + a_login + ":" + a_password + "@" + a_domain

			curl_handle := curl_easy.init
			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url + "/configok.cgi?toggleezpairing=1")
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string.object_id)
			l_result := curl_easy.perform (curl_handle)
			curl_easy.cleanup (curl_handle)
			if not l_curl_string.is_empty then
				s := l_curl_string.string
				p := s.substring_index ("<form>", 1)
				if p > 0 then
					p := s.substring_index ("<b>", p + 1)
					if p > 0 then
						e := s.substring_index ("</b>", p + 1)
						if e > p then
							s := s.substring (p + 3, e - 1)
							p := s.index_of ('<', 1)
							if p > 0 then
								s := s.substring (1, p - 1)
								Result := s.twin
								Result.replace_substring_all ("&eacute;", "e")
							end
						end
					end
				end
			end
		end

	wifi_config (a_html: STRING): TUPLE [activated: BOOLEAN; canal: STRING; wifikey: STRING]
		local
			p,e: INTEGER
			s: STRING
			r: like wifi_config
		do
			create r
			--| Canal
			p := a_html.substring_index ("wifi_channel", 1)
			if p > 0 then
				e := a_html.index_of (';', p)
				if e > 0 then
					s := a_html.substring (p, e - 1)
					p := s.index_of (''', 1)
					if p > 0 then
						e := s.last_index_of (''', s.count)
						if e > p then
							r.canal := s.substring (p + 1, e - 1)
						end
					end
				end
			end

			--| activated
			p := a_html.substring_index ("enblWifi", 1)
			if p > 0 then
				e := a_html.index_of (';', p)
				if e > 0 then
					s := a_html.substring (p, e - 1)
					p := s.index_of (''', 1)
					if p > 0 then
						e := s.last_index_of (''', s.count)
						if e > p then
							s := s.substring (p + 1, e - 1)
							if s.is_case_insensitive_equal ("1") then
								r.activated := True
							else
								r.activated := False
							end
						end
					end
				end
			end

			p := a_html.substring_index ("name=wifi_key", 1)
			if p > 0 then
				p := a_html.substring_index ("value='", p + 1)
				if p > 0 then
					p := a_html.index_of (''', p + 1)
					if p > 0 then
						e := a_html.index_of (''', p + 1)
						if e > p then
							s := a_html.substring (p + 1, e - 1)
							r.wifikey := s.twin
						end
					end
				end
			end
			Result := r
		end

	easy_wifi_details (a_html: STRING): TUPLE [activated: BOOLEAN; ssid: STRING]
		local
			p,e: INTEGER
			s: STRING
			r: like easy_wifi_details
		do
			create r
			p := a_html.substring_index ("wifiEssid.value", 1)
			if p > 0 then
				e := a_html.index_of (';', p)
				if e > 0 then
					s := a_html.substring (p, e - 1)
					p := s.index_of (''', 1)
					if p > 0 then
						e := s.last_index_of (''', s.count)
						if e > p then
							r.ssid := s.substring (p + 1, e - 1)
						end
					end
				end
			end
			p := a_html.substring_index ("Installation WiFi Facile", 1)
			if p > 0 then
				p := a_html.substring_index ("btnEZPairingApply()", p + 1)
				if p > 0 then
					e := a_html.index_of ('>', p + 1)
					if e > p then
						s := a_html.substring (p, e - 1)
						p := s.substring_index ("value='", 1)
						if p > 0 then
							p := s.index_of (''', p)
							e := s.last_index_of (''', s.count)
							if e > p then
								s := s.substring (p + 1, e - 1)
--								print (s + "%N")
								if s.is_case_insensitive_equal ("Activer") then
									r.activated := False
								else
									check s.is_case_insensitive_equal ("D&eacute;sactiver")  end
									r.activated := True
								end
							end
						end
					end
				end
			end

			Result := r
		end

feature {NONE} -- Implementation

	site_login: STRING
	site_password: STRING
	site_domain: STRING

	curl: CURL_EXTERNALS is
			-- cURL externals
		once
			create Result
		end

	curl_easy: CURL_EASY_EXTERNALS is
			-- cURL easy externals
		once
			create Result
		end

	curl_handle: POINTER;
			-- cURL handle

end
