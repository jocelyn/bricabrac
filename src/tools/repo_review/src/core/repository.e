note
	description: "Summary description for {REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPOSITORY

feature {NONE} -- Initialization

	make
		do
			create uuid
		end

feature -- Access

	uuid: UUID

	has_uuid: BOOLEAN
		do
			Result := uuid /~ create {UUID}
		end

	location: STRING
		deferred
		end

feature -- Element change

	set_uuid (u: like uuid)
		do
			uuid := u
		end

--	set_location (v: like location)
--		require
--			v_attached: v /= Void
--		do
--			location := v
--		ensure
--			location_set: v ~ location
--		end

end
