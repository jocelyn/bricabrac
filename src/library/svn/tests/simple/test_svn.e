note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEST_SVN

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			create svn
--			svn.set_svn_executable_path ("path-to-svn-executable") -- by default "svn"

--			test_statuses
			test_logs
		end

	svn: SVN_ENGINE

feature -- Test

	test_statuses
		do
			if attached svn.statuses ("c:\_dev\trunk\Src\scripts", True, False, False) as lst then
				from
					lst.start
				until
					lst.after
				loop
					display_status (lst.item_for_iteration)
					lst.forth
				end
			end
		end

	test_logs
		do
			if attached svn.logs ("https://svn.eiffel.com/eiffelstudio/trunk", True, 0 , 0, 10) as lst then
				from
					lst.start
				until
					lst.after
				loop
					display_revision (lst.item_for_iteration)
					lst.forth
				end
			end
		end

feature -- Status

feature -- Access

	display_status (s: SVN_STATUS_INFO)
		do
			print ("[" + s.wc_status + "] " + s.display_path + ": " + s.wc_revision.out + "%N")
		end

	display_revision (r: SVN_REVISION_INFO)
		do
			print ("[" + r.revision.out + "] " + r.author + ": ")
			if attached r.log_message as log then
				if log.has ('%N') then
					print ("%N" + log)
				else
					print (log)
				end
			end
			if attached r.paths as lst then
				if lst.count > 0 then
					print ("%N")
				end
				from
					lst.start
				until
					lst.after
				loop
					if attached lst.item_for_iteration as p_data then
						print ("%T[" + p_data.action + "] <" + p_data.kind + "> " + p_data.path + "%N")
					end
					lst.forth
				end
			end
			print ("%N")
		end

feature -- Change

end
