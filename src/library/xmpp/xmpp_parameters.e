note
	description: "Summary description for {XMPP_PARAMETERS}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_PARAMETERS

feature -- Access

	host: STRING assign set_host
			-- Host name

	port: INTEGER assign set_port
			-- XMPP port

	server_name: STRING assign set_server_name
			-- XMPP's server name

	user: STRING assign set_user
			-- Username for the XMPP connection

	password: STRING assign set_password
			-- Password for the XMPP connection

feature -- Element change

	set_host (v: like host)
			-- Set `host' to `v'
		do
			host := v
		end

	set_port (v: like port)
			-- Set `port' to `v'
		do
			port := v
		end

	set_server_name (v: like server_name)
			-- Set `server_name' to `v'
		do
			server_name := v
		end

	set_user (v: like user)
			-- Set `user' to `v'
		do
			user := v
		end

	set_password (v: like password)
			-- Set `password' to `v'
		do
			password := v
		end

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
