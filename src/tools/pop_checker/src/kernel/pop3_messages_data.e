note
	description: "Summary description for {POP3_MESSAGES_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POP3_MESSAGES_DATA

create
	make

feature {NONE} -- Initialization

	make (a_uuid: like uuid)
		do
			uuid := a_uuid
			create logs.make_empty
			create messages.make (100)
			messages.compare_objects
		end

feature -- Access

	uuid: STRING

	messages: HASH_TABLE [POP3_MESSAGE, STRING]

	offline_messages: detachable ARRAYED_LIST [TUPLE [id: like counter; message: POP3_MESSAGE]]

	messages_count: INTEGER
		do
			if attached messages as msgs then
				Result := msgs.count
			else
				Result := -1
			end
		end

	counter: NATURAL_64

	messages_by_index: ARRAY [POP3_MESSAGE]
		local
			l_messages: like messages
			m: POP3_MESSAGE
		do
			l_messages := messages
			create Result.make (1, l_messages.count)
			from
				l_messages.start
			until
				l_messages.after
			loop
				m := l_messages.item_for_iteration
				Result [m.index] := m
--				Result.force ()
				l_messages.forth
			end
		end

	has_log: BOOLEAN
		do
			Result := attached logs as l and then not l.is_empty
		end

	logs: STRING_32

	file_name: STRING
		do
			Result := uuid.string
--			Result.replace_substring_all ("://", "__")
--			Result.replace_substring_all ("%%", "#")
--			Result.replace_substring_all ("@", "_at_")
--			Result.replace_substring_all (".", "_")
--			Result.replace_substring_all (":", "_")
		end

feature -- Basic operations

	reset_logs
		do
			logs.wipe_out
		end

	add_log (a_log: STRING_32)
		require
			a_log_attached: a_log /= Void
		do
			logs.prepend_string (a_log + "%N")
		end

	keep (a_lst: LIST [POP3_MESSAGE])
		local
			l_uuids: ARRAYED_LIST [STRING]
			l_uid: detachable STRING
			c: CURSOR
			mesgs: like messages
		do
			from
				c := a_lst.cursor
				create l_uuids.make (a_lst.count)
				l_uuids.compare_objects
				a_lst.start
			until
				a_lst.after
			loop
				l_uid := a_lst.item.uid
				if l_uid /= Void then
					l_uuids.extend (l_uid)
				end
				a_lst.forth
			end
			a_lst.go_to (c)

			from
				mesgs := messages
				mesgs.start
			until
				mesgs.after
			loop
				l_uid := mesgs.key_for_iteration
				if not l_uuids.has (l_uid) then
					record_offline (mesgs.item_for_iteration)
					mesgs.remove (l_uid)
				else
					mesgs.forth
				end
			end
		end

	record_offline (a_msg: POP3_MESSAGE)
		require
			a_msg_attached: a_msg /= Void
		local
			l_offline: like offline_messages
		do
			l_offline := offline_messages
			if l_offline = Void then
				counter := 0
				create l_offline.make (100)
				l_offline.compare_objects
				offline_messages := l_offline
			end
			counter := counter + 1
			l_offline.force ([counter, a_msg])
			a_msg.reset_index
		end

feature -- Element change

end
