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
			servername := "jabber.origo.ethz.ch"
			host := servername
			port := 5222
			user := "bricabrac"
			password := "ezadWEB8!"
		end

feature -- Access

	host: STRING
	port: INTEGER
	servername: STRING

	user: STRING
	password: STRING

end
