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
			i: INTEGER
		do
			l_messages := messages
			create Result.make (1, l_messages.count)
			from
				l_messages.start
			until
				l_messages.after
			loop
				m := l_messages.item_for_iteration
				i := i.max (m.index)
				Result [m.index] := m
--				Result.force ()
				l_messages.forth
			end
		end

	messages_by_date: ARRAY [POP3_MESSAGE]
		local
			l_messages: like messages
			m: POP3_MESSAGE
			lst: DS_ARRAYED_LIST [POP3_MESSAGE]
		do
			l_messages := messages
			create lst.make (l_messages.count)
			from
				l_messages.start
			until
				l_messages.after
			loop
				m := l_messages.item_for_iteration
				lst.force_last (m)
				l_messages.forth
			end

			lst.sort (message_sorter_by_date)
			if attached lst.to_array as arr then
				Result := arr
			else
				Result := <<>> --|  messages_by_index
				check should_not_occur: False end
			end
		end

	offline_messages_by_date: ARRAY [POP3_MESSAGE]
		local
			lst: DS_ARRAYED_LIST [POP3_MESSAGE]
		do
			if attached offline_messages as l_offmesgs then
				from
					create lst.make (l_offmesgs.count)
					l_offmesgs.start
				until
					l_offmesgs.after
				loop
					lst.force_last (l_offmesgs.item.message)
					l_offmesgs.forth
				end
				lst.sort (message_sorter_by_date)
				if attached lst.to_array as arr then
					Result := lst.to_array
				else
					Result := <<>>
					check should_not_occur: False end
				end
			else
				Result := <<>>
			end
		end

	message_sorter_by_date: DS_QUICK_SORTER [POP3_MESSAGE]
		local
			comparator: AGENT_BASED_EQUALITY_TESTER [POP3_MESSAGE]
		once
			create comparator.make (agent compare_date)
			create Result.make (comparator)
		end

	compare_date (m1, m2: POP3_MESSAGE): BOOLEAN
		local
			d1, d2: detachable DATE_TIME
		do
			d1 := m1.header_date_time
			d2 := m2.header_date_time
			if d1 = Void or d2 = Void then
				Result := m1.index < m2.index
			elseif d1 = Void then
				Result := False
			else
				Result := d1 < d2
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
				if l_uuids.has (l_uid) then
					mesgs.forth
				else
					record_offline (mesgs.item_for_iteration)
					mesgs.remove (l_uid)
				end
			end
--			if attached offline_messages as l_offs then
--				update_offline_messages (l_offs)
--			end
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
			a_msg.update_index (counter.as_integer_32)
			l_offline.force ([counter, a_msg])
			a_msg.reset_index
		end

--	update_offline_messages (a_offline_messages: like offline_messages)
--		do
--			from
--				a_offline_messages.start
--			until
--				a_offline_messages.after
--			loop
--				if attached a_offline_messages.item as l_off then
--					l_off.message.update_index (l_off.id.to_integer_32)
--				end
--				a_offline_messages.forth
--			end
--		end

feature -- Element change

end
