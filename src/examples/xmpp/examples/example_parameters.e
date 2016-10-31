note
	description: "Summary description for {EXAMPLE_PARAMETERS}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	EXAMPLE_PARAMETERS

feature {NONE} -- Initialization

	initialize_parameters
		do
			servername := "im.apinc.org"
			host := servername
			port := 5222
			user := "bricabrac"
			password := "PASSWORD!!!"
		end

feature -- Access

	host: STRING
	port: INTEGER
	servername: STRING

	user: STRING
	password: STRING

;note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
