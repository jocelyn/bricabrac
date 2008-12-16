note
	description: "Summary description for {XMPP_LOGGER}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_LOGGER

create
	make

feature {NONE} -- Initialization

	make (a_level: INTEGER; a_out: PLAIN_TEXT_FILE)
			-- Create logger for level `a_level', with output `a_out'
		do
			level := a_level
			output := a_out
		end

feature -- Access

	level: INTEGER
			-- Log's level

	output: PLAIN_TEXT_FILE
			-- Log's output

feature -- Basic operation

	log (msg: STRING; a_lev: INTEGER)
			-- Log message `msg' for level `a_lev'
		do
			if a_lev <= level then
				output.put_string (msg)
				output.put_new_line
			end
		end

	set_error_level
			-- Set log's level to `log_error'
		do
			level := log_error
		end

	set_warning_level
			-- Set log's level to `log_warning'	
		do
			level := log_warning
		end

	set_info_level
			-- Set log's level to `log_info'
		do
			level := log_info
		end

	set_debug_level
			-- Set log's level to `log_debug'
		do
			level := log_debug
		end

	set_verbose_level
			-- Set log's level to `log_verbose'
		do
			level := log_verbose
		end

feature -- Constants

	log_error: INTEGER = 0
	log_warning: INTEGER = 1
	log_info: INTEGER = 2
	log_debug: INTEGER = 3
	log_verbose: INTEGER = 4

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.net/
		]"
end
