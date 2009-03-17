note
	description: "Summary description for {TWITTER_JSON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TWITTER_JSON

inherit
	TWITTER_I

create
	make,
	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: STRING)
		do
			create twitter_api.make (a_username, a_password)
			twitter_api.set_json_format
		end

	make_with_source (a_username, a_password: STRING; a_source: STRING)
		do
			make (a_username, a_password)
			twitter_api.set_application_source (a_source)
		end

feature -- Twitter: Status Methods		

	show_status (a_id: INTEGER): detachable TWITTER_STATUS
			-- single status, specified by the id parameter below.
			-- The status's author will be returned inline.
		do
			if attached twitter_api.show_status (a_id) as s then
				if attached parsed_json (s) as j then
					create Result
				end
			end
		end

	update_status (a_status: STRING; in_reply_to_status_id: INTEGER): detachable TWITTER_STATUS
			-- Updates the authenticating user's status.
		do
			if attached twitter_api.update_status (a_status, in_reply_to_status_id) as s then
				if attached parsed_json (s) as j then
					Result := twitter_status (Void, j)
				end
			end
		end

feature -- Twitter: User Methods		

	show_user (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Returns extended information of a given user, specified by ID or screen name as per the required id parameter below.  This information includes design settings, so third party developers can theme their widgets according to a given user's preferences. You must be properly authenticated to request the page of a protected user.
			--URL: http://twitter.com/users/show/id.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--One of the following is required:
			--    * id.  The ID or screen name of a user.
			--		Ex: http://twitter.com/users/show/12345.json
			--		or http://twitter.com/users/show/bob.xml
			--    * user_id. May be used in place of "id" parameter above. The user id of a user. Ex: http://twitter.com/users/show.xml?user_id=12345
			--    * screen_name. May be used in place of "id" parameter above. The screen name of a user. Ex: http://twitter.com/users/show.xml?screen_name=bob
			--Returns: extended user information element
		do
			if attached twitter_api.show_user (a_id, a_screen_name) as s then
				if attached parsed_json (s) as j then
					Result := twitter_user (Void, j)
				end
			end
		end

feature -- Twitter: Account Methods

	verify_credentials: detachable TWITTER_USER
			--Returns an HTTP 200 OK response code and a representation of the requesting user
			-- if authentication was successful;
			-- returns a 401 status code and an error message if not.
			-- Use this method to test if supplied user credentials are valid.
			--URL: http://twitter.com/account/verify_credentials.format
			--Formats: xml, json
			--Method(s): GET
			--Returns: extended user information element
		local
			err: DEVELOPER_EXCEPTION
		do
			if attached twitter_api.verify_credentials as s then
				if attached parsed_json (s) as j then
					if attached string_value_from_json (j, "error") as l_error then
						create err
						err.set_message (l_error)
						err.raise
					else
						Result := twitter_user (Void, j)
					end
				end
			end
		end

	end_session
			--	function endSession() {
		local
			s: STRING
		do
			s := twitter_api.end_session
		end

	rate_limit_status: detachable TUPLE [ reset_time_in_seconds: INTEGER; remaining_hits: INTEGER; hourly_limit: INTEGER; reset_time: detachable STRING]
			-- Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour. Calls to rate_limit_status do not count against the rate limit.  If authentication credentials are provided, the rate limit status for the authenticating user is returned.  Otherwise, the rate limit status for the requester's IP address is returned.
			-- URL: http://twitter.com/account/rate_limit_status.format
			-- Formats: xml, json
			-- Method(s): GET
			-- Parameters: none
			-- Ex:{"reset_time_in_seconds":1237292716,"remaining_hits":100,"hourly_limit":100,"reset_time":"Tue Mar 17 12:25:16 +0000 2009"}			
		do
			if attached twitter_api.rate_limit_status as s then
				if attached parsed_json (s) as j then
					create Result
					Result.reset_time_in_seconds := integer_value_from_json (j, "reset_time_in_seconds")
					Result.remaining_hits := integer_value_from_json (j, "remaining_hits")
					Result.hourly_limit := integer_value_from_json (j, "hourly_limit")
					Result.reset_time := string_value_from_json (j, "reset_time")
				end
			end
		end

feature -- Implementation: Factory

	twitter_status (a_status: detachable like twitter_status; a_json: JSON_VALUE): TWITTER_STATUS
			-- Fill `a_status' from `a_json'
		require
			a_json_attached: a_json /= Void
		do
			if a_status /= Void then
				Result := a_status
			else
				create Result
			end
			Result.set_id (integer_value_from_json (a_json, "id"))
			Result.set_text (string_value_from_json (a_json, "text"))
			Result.set_in_reply_to_user_id (integer_value_from_json (a_json, "in_reply_to_user_id"))
			Result.set_in_reply_to_status_id (integer_value_from_json (a_json, "in_reply_to_status_id"))
			Result.set_in_reply_to_screen_name (string_value_from_json (a_json, "in_reply_to_screen_name"))
			Result.set_created_at (string_value_from_json (a_json, "created_at"))
			Result.set_truncated (boolean_value_from_json (a_json, "truncated"))
			Result.set_favorited (boolean_value_from_json (a_json, "favorited"))
			Result.set_source (string_value_from_json (a_json, "source"))

			if attached {JSON_OBJECT} json_value (a_json, "user") as l_user then
				Result.set_user (twitter_user (Void, l_user))
			end
		end

	twitter_user (a_user: detachable like twitter_user; a_json: JSON_VALUE): TWITTER_USER
			-- Fill `a_user' from `a_json'
		require
			a_json_attached: a_json /= Void
		do
			if a_user /= Void then
				Result := a_user
			else
				create Result
			end
			Result.set_id (integer_value_from_json (a_json, "id"))
			Result.set_created_at (string_value_from_json (a_json, "created_at"))
			Result.set_name (string_value_from_json (a_json, "name"))
			Result.set_screen_name (string_value_from_json (a_json, "screen_name"))
			Result.set_location (string_value_from_json (a_json, "location"))
			Result.set_description (string_value_from_json (a_json, "description"))
			Result.set_profile_image_url (string_value_from_json (a_json, "profile_image_url"))
			Result.set_url (string_value_from_json (a_json, "url"))
			Result.set_protected (boolean_value_from_json (a_json, "protected"))
			Result.set_followers_count (integer_value_from_json (a_json, "followers_count"))

			if attached {JSON_OBJECT} json_value (a_json, "status") as l_status then
				Result.set_status (twitter_status (Void, l_status))
			end
		end

feature -- Implementation

	print_last_json_data 
			-- Print `last_json' data
		do
			internal_print_json_data (last_json, "  ")
		end

feature {NONE} -- Implementation

	twitter_api: TWITTER_API
			-- Twitter object

	last_json: detachable JSON_VALUE

	parsed_json (a_json_text: STRING): detachable JSON_VALUE
		local
			j: JSON_PARSER
		do
			create j.make_parser (a_json_text)
			Result := j.parse_json
			last_json := Result
		end

	json_value (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable JSON_VALUE
		local
			l_id: JSON_STRING
			l_ids: LIST [STRING]
		do
			Result := a_json_data
			if Result /= Void then
				if a_id /= Void and then not a_id.is_empty then
					from
						l_ids := a_id.split ('.')
						l_ids.start
					until
						l_ids.after or Result = Void
					loop
						create l_id.make_json (l_ids.item)
						if attached {JSON_OBJECT} Result as v_data then
							if v_data.has_key (l_id) then
								Result := v_data.item (l_id)
							else
								Result := Void
							end
						else
							Result := Void
						end
						l_ids.forth
					end
				end
			end
		end

	internal_print_json_data (a_json_data: detachable JSON_VALUE; a_offset: STRING)
		local
			obj: HASH_TABLE [JSON_VALUE, JSON_STRING]
		do
			if attached {JSON_OBJECT} a_json_data as v_data then
				obj	:= v_data.map_representation
				from
					obj.start
				until
					obj.after
				loop
					print (a_offset)
					print (obj.key_for_iteration.item)
					if attached {JSON_STRING} obj.item_for_iteration as j_s then
						print (": " + j_s.item)
					elseif attached {JSON_NUMBER} obj.item_for_iteration as j_n then
						print (": " + j_n.item)
					elseif attached {JSON_BOOLEAN} obj.item_for_iteration as j_b then
						print (": " + j_b.item.out)
					elseif attached {JSON_NULL} obj.item_for_iteration as j_null then
						print (": NULL")
					elseif attached {JSON_ARRAY} obj.item_for_iteration as j_a then
						print (": {%N")
						internal_print_json_data (j_a, a_offset + "  ")
						print (a_offset + "}")
					elseif attached {JSON_OBJECT} obj.item_for_iteration as j_o then
						print (": {%N")
						internal_print_json_data (j_o, a_offset + "  ")
						print (a_offset + "}")
					end
					print ("%N")
					obj.forth
				end
			end
		end

	integer_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): INTEGER
		do
			if
				attached {JSON_NUMBER} json_value (a_json_data, a_id) as v and then
				v.numeric_type = v.integer_type
			then
				Result := v.item.to_integer
			end
		end

	boolean_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): BOOLEAN
		do
			if attached {JSON_BOOLEAN} json_value (a_json_data, a_id) as v then
				Result := v.item
			end
		end

	string_value_from_json (a_json_data: detachable JSON_VALUE; a_id: STRING): detachable STRING
		do
			if attached {JSON_STRING} json_value (a_json_data, a_id) as v then
				Result := v.item
			end
		end

end
