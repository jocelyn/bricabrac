note
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

	make
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
			if
				attached site_login as l_site_login and
				attached site_password as l_site_password and
				attached site_domain as l_site_domain
			then
				if attached wifi_config_for (l_site_login, l_site_password, l_site_domain) as l_wifi_cfg then
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
					if attached set_wifi_status_for (l_site_login, l_site_password, l_site_domain, cfg, st) as r then
						print ("Wifi network: change status -> " + r)
						io.put_new_line
					else
						failed := True
						print ("Wifi network-> No information on wifi 'toggle' operation")
						io.put_new_line
					end
					if attached wifi_config_for (l_site_login, l_site_password, l_site_domain) as l_op_wifi_cfg then
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
				end
			else
				check has_login_pass_domain: False end
				failed := True
				print ("Error: missing login,password and domain parameters .%N")
			end
			if failed then
				print ("Wifi network: operation failed !!!%N")
			end
		end

	process_easy_wifi (requested_easy_status: INTEGER)
		local
			failed, toggle_easy_requested: BOOLEAN
		do
			if
				attached site_login as l_site_login and
				attached site_password as l_site_password and
				attached site_domain as l_site_domain
			then
				if attached easy_wifi_details_for (l_site_login, l_site_password, l_site_domain) as l_easy_wifi_details then
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
					if attached toggle_easy_wifi_for (l_site_login, l_site_password, l_site_domain) as s then
						print ("Change status -> " + s)
						io.put_new_line
					else
						failed := True
						print ("Easy Wifi -> No information on easy wifi 'toggle' operation")
						io.put_new_line
					end
					if attached easy_wifi_details_for (l_site_login, l_site_password, l_site_domain) as l_op_easy_wifi_details then
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
				end
			else
				check has_login_pass_domain: False end
				failed := True
				print ("Error: missing login,password and domain parameters .%N")
			end
			if failed then
				print ("Easy Wifi: operation failed !!!%N")
			end
		end

	get_parameters
		local
			s: detachable STRING
			ini_fn: STRING
			f: RAW_FILE
			vars: LINKED_LIST [attached like parameters_from_line]
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
					if attached parameters_from_line (f.last_string) as pars then
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
				s := question ("Enter admin username", Void)
				site_login := s
				vars.extend (["login", s])
			end
			if site_password = Void then
				m := True
				s := question ("Enter admin password", Void)
				site_password := s
				vars.extend (["password", s])
			end
			if site_domain = Void then
				m := True
				s := question ("Enter livebox's domain", "192.168.1.1")
				site_domain := s
				vars.extend (["domain", s])
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

	question (m: STRING; d: detachable STRING): STRING
		local
			s, l_reply: detachable STRING
		do
			from
			until
				l_reply /= Void
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
					l_reply := s
				end
			end
			Result := l_reply
		ensure
			result_attached: Result /= Void
		end

	parameter_key (n: STRING): INTEGER
		local
			i: INTEGER
			u,l: INTEGER
		do
			l := crypt_lower
			u := crypt_upper
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
			l := crypt_lower
			u := crypt_upper
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
			l := crypt_lower
			u := crypt_upper
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

	crypt_lower: INTEGER = 32
	crypt_upper: INTEGER = 126

	parameters_to_line (pars: attached like parameters_from_line): STRING
		local
			n,v: detachable STRING
		do
			create Result.make (10)
			n := pars.name
			v := pars.value
			Result.append_string (n)
			Result.append_character ('=')
			Result.append_string (crypted_parameter_value (n, v))
		end

	parameters_from_line (a_line: detachable STRING): detachable TUPLE [name: STRING; value: STRING]
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

	wifi_config_for (a_login, a_password, a_domain: STRING): detachable like wifi_config
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


	set_wifi_status_for (a_login, a_password, a_domain: STRING; a_config: like wifi_config; a_activated: BOOLEAN): detachable STRING
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			s: STRING
			p,e: INTEGER
		do
			if a_config /= Void and then a_config.activated /= a_activated then
				l_url := "http://" + a_login + ":" + a_password + "@" + a_domain
				if
					attached a_config.canal as l_canal and
					attached a_config.wifikey as l_wifikey
				then
					l_url.append_string ("/wifiok.cgi?wifiChannel=" + l_canal + "&wifiKey63=" + l_wifikey + "&enblWifi=")
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
										Result := s.string
										Result.replace_substring_all ("&eacute;", "e")
									end
								end
							end
						end
					end

				end
			end
		end

	easy_wifi_details_for (a_login, a_password, a_domain: STRING): detachable like easy_wifi_details
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

	toggle_easy_wifi_for (a_login, a_password, a_domain: STRING): detachable STRING
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
								Result := s.string
								Result.replace_substring_all ("&eacute;", "e")
							end
						end
					end
				end
			end
		end

	wifi_config (a_html: STRING): detachable TUPLE [activated: BOOLEAN; canal: STRING; wifikey: STRING]
		local
			p,e: INTEGER
			s: STRING
			r: like wifi_config
			l_canal, l_wifikey: detachable STRING
			l_activated, l_activated_set: BOOLEAN
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
							l_canal := s.substring (p + 1, e - 1)
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
							l_activated_set := True
							l_activated := s.is_case_insensitive_equal ("1")
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
							l_wifikey := s.string
						end
					end
				end
			end
			if l_canal /= Void and l_wifikey /= Void and l_activated_set then
				Result := [l_activated, l_canal, l_wifikey]
				check Result.activated = l_activated end
				check Result.canal ~ l_canal end
				check Result.wifikey ~ l_wifikey end
			end
		end

	easy_wifi_details (a_html: STRING): detachable TUPLE [activated: BOOLEAN; ssid: STRING]
		local
			p,e: INTEGER
			s: STRING
			l_ssid: detachable STRING
			l_activated, l_activated_set: BOOLEAN
		do
			p := a_html.substring_index ("wifiEssid.value", 1)
			if p > 0 then
				e := a_html.index_of (';', p)
				if e > 0 then
					s := a_html.substring (p, e - 1)
					p := s.index_of (''', 1)
					if p > 0 then
						e := s.last_index_of (''', s.count)
						if e > p then
							l_ssid := s.substring (p + 1, e - 1)
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
								l_activated_set := True
								if s.is_case_insensitive_equal ("Activer") then
									l_activated := False
								else
									check s.is_case_insensitive_equal ("D&eacute;sactiver")  end
									l_activated := True
								end
							end
						end
					end
				end
			end
			if l_activated_set and l_ssid /= Void then
				Result := [l_activated, l_ssid]
				check Result.ssid ~ l_ssid end
			end
		end

feature {NONE} -- Implementation

	site_login: detachable STRING
	site_password: detachable STRING
	site_domain: detachable STRING

	curl: CURL_EXTERNALS
			-- cURL externals
		once
			create Result
		end

	curl_easy: CURL_EASY_EXTERNALS
			-- cURL easy externals
		once
			create Result
		end

	curl_handle: POINTER;
			-- cURL handle

end
