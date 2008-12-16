note
	description: "Summary description for {EXAMPLE_PARAMETERS}."
	author: "Jocelyn Fiat (jfiat@eiffelsolution.com)"
	date: "$Date$"
	revision: "$Revision$"

class
	EXAMPLE_PARAMETERS

feature {NONE} -- Initialization

	initialize_parameters
		do
			servername := "SET YOUR JABBER SERVER NAME"
			host := servername
			port := 5222
			user := "SET YOUR JABBER USERNAME"
			password := "SET YOUR JABBER PASSWORD"
		end

feature -- Access

	host: STRING
	port: INTEGER
	servername: STRING

	user: STRING
	password: STRING

end
