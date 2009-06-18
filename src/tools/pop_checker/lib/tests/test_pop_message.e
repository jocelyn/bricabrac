note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_POP_MESSAGE

inherit
	EQA_TEST_SET

feature -- Test routines

	test_date_time_from_string
			-- New test routine
		local
			m: POP3_MESSAGE
			dt: DATE_TIME
		do
			create m.make (1)
			dt := m.date_time_from_string ("17 Jun 2009 18:53:14 -0000")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)

			dt := m.date_time_from_string ("Mon, 17 Jun 2009 18:53:14 -0000")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)

			dt := m.date_time_from_string ("17 Jun 2009 18:53:14")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)

			dt := m.date_time_from_string ("Mon, 17 Jun 2009 18:53:14")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)

			dt := m.date_time_from_string ("Mon, 17 Jun 2009 18:53:14 -0300")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18 + 3)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)

			dt := m.date_time_from_string ("Mon, 17 Jun 2009 18:53:14 -0300 (V)")
			assert ("Error with analyze", dt /= Void)
			assert ("Error with year", dt.year = 2009)
			assert ("Error with month", dt.month = 6)
			assert ("Error with day", dt.day = 17)
			assert ("Error with hour", dt.hour = 18 + 3)
			assert ("Error with min", dt.minute = 53)
			assert ("Error with sec", dt.second = 14)
		end

end
