note
	description: "Summary description for {TWITTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TWITTER_API

inherit
	REFACTORING_HELPER

create
	make,
	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: STRING)
		do
			username := a_username.string
			password := a_password.string
			credentials := username + ":" + password
			application_source := Void

			format := "json"
		end

	make_with_source (a_username, a_password: STRING; a_source: like application_source)
		do
			make (a_username, a_password)
			set_application_source (a_source)
		end

feature -- Access

	username: STRING
	password: STRING
	credentials: STRING
			-- Username:password format string

	format: STRING
			-- Default format


	http_status: INTEGER
		--	/* Contains the last HTTP status code returned */

	last_api_call: detachable STRING
		--	/* Contains the last API call */

	application_source: detachable STRING
		--	/* Contains the application calling the API */

feature -- status report

	format_is_xml: BOOLEAN
		do
			Result := format = xml_id
		end

	format_is_json: BOOLEAN
		do
			Result := format = json_id
		end

	format_is_rss: BOOLEAN
		do
			Result := format = rss_id
		end

	format_is_atom: BOOLEAN
		do
			Result := format = atom_id
		end

feature -- Element change

	set_json_format
		do
			format := json_id
		end

	set_xml_format
		do
			format := xml_id
		end

	set_rss_format
		do
			format := rss_id
		end

	set_atom_format
		do
			format := atom_id
		end

	set_application_source (a_source: like application_source)
		do
			application_source := a_source
		end

feature -- Twitter: Status Methods

	public_timeline (a_since_id: INTEGER): STRING
			-- getPublicTimeline($format, $since_id = 0)
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("statuses/public_timeline." + format, Void)
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			Result := api_call (l_api_call)
		end

--	function getFriendsTimeline($format, $id = NULL, $since = NULL) {
--		if ($id != NULL) {
--			$api_call = sprintf("http://twitter.com/statuses/friends_timeline/%s.%s", $id, $format);
--		}
--		else {
--			$api_call = sprintf("http://twitter.com/statuses/friends_timeline.%s", $format);
--		}
--		if ($since != NULL) {
--			$api_call .= sprintf("?since=%s", urlencode($since));
--		}
--		return $this->APICall($api_call, true);
--	}
--	
--	function getUserTimeline($format, $id = NULL, $count = 20, $since = NULL) {
--		if ($id != NULL) {
--			$api_call = sprintf("http://twitter.com/statuses/user_timeline/%s.%s", $id, $format);
--		}
--		else {
--			$api_call = sprintf("http://twitter.com/statuses/user_timeline.%s", $format);
--		}
--		if ($count != 20) {
--			$api_call .= sprintf("?count=%d", $count);
--		}
--		if ($since != NULL) {
--			$api_call .= sprintf("%ssince=%s", (strpos($api_call, "?count=") === false) ? "?" : "&", urlencode($since));
--		}
--		return $this->APICall($api_call, true);
--	}

	show_status (a_id: INTEGER): STRING
			-- Returns a single status, specified by the id parameter below.  The status's author will be returned inline.
			-- URL: http://twitter.com/statuses/show/id.format
			-- Formats: xml, json
			-- Method(s): GET
			-- Parameters:
			--     * id.  Required.  The numerical ID of the status you're trying to retrieve.  Ex: http://twitter.com/statuses/show/123.xml
			-- Returns: status element
		do
			Result := api_call (twitter_url ("statuses/show/" + a_id.out + "." + format, Void))
		end

	update_status (a_status: STRING; a_in_reply_to_status_id: INTEGER): STRING
			--Updates the authenticating user's status.  Requires the status parameter specified below.  Request must be a POST.  A status update with text identical to the authenticating user's current status will be ignored.
			--URL: http://twitter.com/statuses/update.format
			--Formats: xml, json.  Returns the posted status in requested format when successful.
			--Method(s): POST
			--Parameters:
			--    * status.  Required.  The text of your status update.  Be sure to URL encode as necessary.  Should not be more than 140 characters.
			--    * in_reply_to_status_id.  Optional.
			--		The ID of an existing status that the status to be posted is in reply to.
			--		This implicitly sets the in_reply_to_user_id attribute of the resulting status to the user ID of the message being replied to.
			--		Invalid/missing status IDs will be ignored.
			--Returns: status element
		require
			vald_format: format_is_xml or format_is_json
		local
			l_status: STRING
			l_api_call: STRING
		do
			l_status := urlencode (stripslashes (urldecode(a_status)))
			check l_status.count <= 140 end
			l_api_call := twitter_url ("statuses/update." + format, <<["status", l_status]>>)
			if a_in_reply_to_status_id > 0 then
				append_parameters_to_url (l_api_call, <<["in_reply_to_status_id", a_in_reply_to_status_id.out]>>)
			end
			Result := api_call_with_details (l_api_call, True, True)
		end

--	function getReplies($format, $page = 0) {
--		$api_call = sprintf("http://twitter.com/statuses/replies.%s", $format);
--		if ($page) {
--			$api_call .= sprintf("?page=%d", $page);
--		}
--		return $this->APICall($api_call, true);
--	}
--	
--	function destroyStatus($format, $id) {
--		$api_call = sprintf("http://twitter.com/statuses/destroy/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}

feature -- Twitter: User Methods
--	
--	function getFriends($format, $id = NULL) {
--		// take care of the id parameter
--		if ($id != NULL) {
--			$api_call = sprintf("http://twitter.com/statuses/friends/%s.%s", $id, $format);
--		}
--		else {
--			$api_call = sprintf("http://twitter.com/statuses/friends.%s", $format);
--		}
--		return $this->APICall($api_call, true);
--	}
--	
--	function getFollowers($format, $id = NULL, $page = 1, $lite = false) {
--		// either get authenticated users followers, or followers of specified id
--		if ($id) {
--			$api_call = sprintf("http://twitter.com/statuses/followers/%s.%s", $id, $format);
--		}
--		else {
--			$api_call = sprintf("http://twitter.com/statuses/followers.%s", $format);
--		}
--		// pagination
--		if ($page > 1) {
--			$api_call .= "?page={$page}";
--		}
--		// this isnt in the documentation, but apparently it works
--		if ($lite) {
--			$api_call .= sprintf("%slite=true", ($page > 1) ? "&" : "?");
--		}
--		return $this->APICall($api_call, true);
--	}
--	
----	function getFeatured($format) {
----		$api_call = sprintf("http://twitter.com/statuses/featured.%s", $format);
----		return $this->APICall($api_call);
----	}

	show_user (a_id: INTEGER; a_screen_name: detachable STRING): STRING
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
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("users/show/" + a_id.out + "." + format, Void)
--				l_api_call := twitter_url ("users/show." + format, <<["user_id", a_id.out]>>)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("users/show." + format, <<["screen_name", a_screen_name]>>)
			end
			if l_api_call /= Void then
				Result := api_call_with_details (l_api_call, True, False)
			else
				create Result.make_empty
			end
		end

feature -- Twitter: Direct Message Methods

	direct_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): STRING
			-- Returns a list of the 20 most recent direct messages sent to the authenticating user.
			-- The XML and JSON versions include detailed information about the sending and recipient users.
			--URL: http://twitter.com/direct_messages.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * since.  Optional.  Narrows the resulting list of direct messages to just those sent
			--		after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting the If-Modified-Since parameter in your HTTP request.
			--		Ex: http://twitter.com/direct_messages.atom?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.
			--		Returns only direct messages with an ID greater than (that is, more recent than) the specified ID.
			--		Ex: http://twitter.com/direct_messages.xml?since_id=12345
			--    * page.  Optional.
			--		Retrieves the 20 next most recent direct messages.
			--		Ex: http://twitter.com/direct_messages.xml?page=3
			--Return: list of direct message elements
		local
			l_api_call: detachable STRING
		do
			l_api_call := twitter_url ("direct_messages." + format, Void)
			if attached a_since_date as l_date then
				append_parameters_to_url (l_api_call, <<["since", urlencode (l_date)]>>)
			end
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_call_with_details (l_api_call, True, False)
		end

	sent_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): STRING
			--Returns a list of the 20 most recent direct messages sent by the authenticating user.
			--The XML and JSON versions include detailed information about the sending and recipient users.
			--URL: http://twitter.com/direct_messages/sent.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * since.  Optional.  Narrows the resulting list of direct messages to just those sent
			--		after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting the If-Modified-Since parameter in your HTTP request.
			--		Ex: http://twitter.com/direct_messages/sent.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.
			--		Returns only sent direct messages with an ID greater than (that is, more recent than) the specified ID.
			--		Ex: http://twitter.com/direct_messages/sent.xml?since_id=12345
			--    * page.  Optional.
			--		Retrieves the 20 next most recent direct messages sent.
			--		Ex: http://twitter.com/direct_messages/sent.xml?page=3
			--Return: list of direct message elements
		local
			l_api_call: detachable STRING
		do
			l_api_call := twitter_url ("direct_messages/sent." + format, Void)
			if attached a_since_date as l_date then
				append_parameters_to_url (l_api_call, <<["since", urlencode (l_date)]>>)
			end
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_call_with_details (l_api_call, True, False)
		end

	new_message (a_user: STRING; a_text: STRING): STRING
			--Sends a new direct message to the specified user from the authenticating user.  Requires both the user and text parameters below.  Request must be a POST.  Returns the sent message in the requested format when successful.
			--URL: http://twitter.com/direct_messages/new.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * user.  Required.  The ID or screen name of the recipient user.
			--    * text.  Required.  The text of your direct message.  Be sure to URL encode as necessary, and keep it under 140 characters.
			--Return: direct message element
		local
			l_text: STRING
			l_api_call: STRING
		do
			l_text := urlencode( stripslashes (urldecode (a_text)))
			check l_text.count <= 140 end

			l_api_call := twitter_url ("direct_messages/new." + format, <<["user", a_user], ["text", l_text]>>)
			Result := api_call_with_details (l_api_call, True, True)
		end

	destroy_message (a_id: INTEGER): STRING
			--Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.
			--URL: http://twitter.com/direct_messages/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the direct message to destroy.  Ex: http://twitter.com/direct_messages/destroy/12345.json or http://twitter.com/direct_messages/destroy/23456.xml
			--Return: list of direct message elements		
		require
			a_id_positive: a_id > 0
		do
			Result := api_call_with_details (twitter_url ("direct_messages/destroy/" + a_id.out + "." + format, Void), True, True)
		end

feature -- Twitter: Friendship Methods

--	
--	function createFriendship($format, $id) {
--		$api_call = sprintf("http://twitter.com/friendships/create/%s.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function destroyFriendship($format, $id) {
--		$api_call = sprintf("http://twitter.com/friendships/destroy/%s.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function friendshipExists($format, $user_a, $user_b) {
--		$api_call = sprintf("http://twitter.com/friendships/exists.%s?user_a=%s&user_b=%s", $format, $user_a, $user_b);
--		return $this->APICall($api_call, true);
--	}

feature -- Twitter: Social Graph Methods

--ids (friends)
--Returns an array of numeric IDs for every user the specified user is following.
--URL: http://twitter.com/friends/ids.xml
--Formats: xml, json
--Method(s): GET
--Parameters:
--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.  Ex: http://twitter.com/friends/ids/bob.xml
--Returns: list of IDs


--ids (followers)
--Returns an array of numeric IDs for every user the specified user is followed by.
--URL: http://twitter.com/followers/ids.format
--Formats: xml, json
--Method(s): GET
--Parameters:
--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.  Ex: http://twitter.com/followers/ids/bob.xml
--Returns: list of IDs

feature -- Twitter: Account Methods

	verify_credentials: STRING
			--Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not.  Use this method to test if supplied user credentials are valid.
			--URL: http://twitter.com/account/verify_credentials.format
			--Formats: xml, json
			--Method(s): GET
			--Returns: extended user information element
		do
			Result := api_call_with_details (twitter_url ("account/verify_credentials." + format, Void), True, False)
		end

	end_session: STRING
			--	function endSession() {
		do
			Result := api_call_with_details (twitter_url ("account/end_session." + format, Void), True, True)
		end

	update_location (a_location: STRING): STRING
			--	function updateLocation($format, $location) {
		obsolete "use update_profile"
		do
			Result := update_profile (Void, Void, Void, a_location, Void)
		end


--	function updateDeliveryDevice($format, $device) {
--		$api_call = sprintf("http://twitter.com/account/update_delivery_device.%s?device=%s", $format, $device);
--		return $this->APICall($api_call, true, true);
--	}
--update_delivery_device
--Sets which device Twitter delivers updates to for the authenticating user.  Sending none as the device parameter will disable IM or SMS updates.
--URL: http://twitter.com/account/update_delivery_device.format
--Formats: xml, json
--Method(s): POST
--Parameters:
--    * device.  Required.  Must be one of: sms, im, none.  Ex: http://twitter.com/account/update_delivery_device.xml?device=im
--Returns: basic user information element		

	update_profile (a_name, a_email, a_url, a_location, a_description: detachable STRING): STRING
		local
			l_api_call: STRING
			l_parameters: detachable ARRAY [detachable TUPLE [STRING_8, STRING_8]]
		do
			create l_parameters.make (1, 5)
			if attached a_name as n and then n.count <= 20 then
				l_parameters[1] := ["name", n]
			end
			if attached a_email as e and then e.count <= 40 then
				l_parameters[2] := ["email", e]
			end
			if attached a_url as u and then u.count <= 100 then
				l_parameters[3] := ["url", u]
			end
			if attached a_location as l and then l.count <= 30 then
				l_parameters[4] := ["location", l]
			end
			if attached a_description as d and then d.count <= 160 then
				l_parameters[5] := ["description", d]
			end

			l_api_call := twitter_url ("account/update_profile." + format, l_parameters)
			Result := api_call_with_details (l_api_call, True, True)
		end

--update_profile_colors
--Sets one or more hex values that control the color scheme of the authenticating user's profile page on twitter.com.  These values are also returned in the /users/show API method.
--URL: http://twitter.com/account/update_profile_colors.format
--Formats: xml, json
--Method(s): POST
--Parameters: one or more of the following parameters must be present.  Each parameter's value must be a valid hexidecimal value, and may be either three or six characters (ex: #fff or #ffffff).
--    * profile_background_color.  Optional.
--    * profile_text_color.  Optional.
--    * profile_link_color.  Optional.
--    * profile_sidebar_fill_color.  Optional.
--    * profile_sidebar_border_color.  Optional.
--Returns: extended user information element

--update_profile_image
--Updates the authenticating user's profile image.  Expects raw multipart data, not a URL to an image.
--URL: http://twitter.com/account/update_profile_image.format
--Formats: xml, json
--Method(s): POST
--Parameters:
--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 700 kilobytes in size.  Images with width larger than 500 pixels will be scaled down.
--Returns: extended user information element

--update_profile_background_image
--Updates the authenticating user's profile background image.  Expects raw multipart data, not a URL to an image.
--URL: http://twitter.com/account/update_profile_background_image.format
--Formats: xml, json
--Method(s): POST
--Parameters:
--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 800 kilobytes in size.  Images with width larger than 2048 pixels will be scaled down.
--Returns: extended user information element

	rate_limit_status: STRING
			--rate_limit_status
			--Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour. Calls to rate_limit_status do not count against the rate limit.  If authentication credentials are provided, the rate limit status for the authenticating user is returned.  Otherwise, the rate limit status for the requester's IP address is returned.
			--URL: http://twitter.com/account/rate_limit_status.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters: none
		local
		do
			Result := api_call (twitter_url ("account/rate_limit_status." + format, Void))
		end

--	function rateLimitStatus($format) {
--		$api_call = sprintf("http://twitter.com/account/rate_limit_status.%s", $format);
--		return $this->APICall($api_call, true);
--	}
--	
--	function getArchive($format, $page = 1) {
--		$api_call = sprintf("http://twitter.com/account/archive.%s", $format);
--		if ($page > 1) {
--			$api_call .= sprintf("?page=%d", $page);
--		}
--		return $this->APICall($api_call, true);
--	}
--	
--	function getFavorites($format, $id = NULL, $page = 1) {
--		if ($id == NULL) {
--			$api_call = sprintf("http://twitter.com/favorites.%s", $format);
--		}
--		else {
--			$api_call = sprintf("http://twitter.com/favorites/%s.%s", $id, $format);
--		}
--		if ($page > 1) {
--			$api_call .= sprintf("?page=%d", $page);
--		}
--		return $this->APICall($api_call, true);
--	}
--	
--	function createFavorite($format, $id) {
--		$api_call = sprintf("http://twitter.com/favorites/create/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function destroyFavorite($format, $id) {
--		$api_call = sprintf("http://twitter.com/favorites/destroy/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function follow($format, $id) {
--		$api_call = sprintf("http://twitter.com/notifications/follow/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function leave($format, $id) {
--		$api_call = sprintf("http://twitter.com/notifications/leave/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function createBlock($format, $id) {
--		$api_call = sprintf("http://twitter.com/blocks/create/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function destroyBlock($format, $id) {
--		$api_call = sprintf("http://twitter.com/blocks/destroy/%d.%s", $id, $format);
--		return $this->APICall($api_call, true, true);
--	}
--	
--	function test($format) {
--		$api_call = sprintf("http://twitter.com/help/test.%s", $format);
--		return $this->APICall($api_call, true);
--	}
--	
--	function downtimeSchedule($format) {
--		$api_call = sprintf("http://twitter.com/help/downtime_schedule.%s", $format);
--		return $this->APICall($api_call, true);
--	}
--	
feature {NONE} -- Implementation

	twitter_url (a_query: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]]): STRING
		do
			Result := url ("http://twitter.com/" + a_query, a_parameters)
		end

	url (a_base_url: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]]): STRING
		do
			create Result.make_from_string (a_base_url)
			append_parameters_to_url (Result, a_parameters)
		end

	append_parameters_to_url (a_url: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]])
		local
			i: INTEGER
			l_first_param: BOOLEAN
		do
			if a_parameters /= Void and then a_parameters.count > 0 then
				if a_url.index_of ('?', 1) > 0 then
					l_first_param := False
				elseif a_url.index_of ('&', 1) > 0 then
					l_first_param := False
				else
					l_first_param := True
				end
				from
					i := a_parameters.lower
				until
					i > a_parameters.upper
				loop
					if attached a_parameters[i] as a_param then
						if l_first_param then
							a_url.append_character ('?')
						else
							a_url.append_character ('&')
						end
						a_url.append_string (a_param.name)
						a_url.append_character ('=')
						a_url.append_string (a_param.value)
						l_first_param := False
					end
					i := i + 1
				end
			end
		end

	api_call (a_api_url: STRING): like api_call_with_details
		do
			Result := api_call_with_details (a_api_url, False, False)
		end

	api_call_with_details (a_api_url: STRING; a_require_credentials: BOOLEAN; a_http_post: BOOLEAN): STRING
		local
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			p: POINTER
		do
			l_url := a_api_url.string
			if attached application_source as l_app_src then
				append_parameters_to_url (l_url, <<["source", l_app_src]>>)
			end

			curl_handle := curl_easy.init

			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url)
			if a_require_credentials then
				curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_userpwd, credentials)
			end
			if a_http_post then
				curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_post, 1)
			end
--			curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_returntransfer, 1)

			curl.global_init
			p := curl.slist_append (p, "Expect:")
			curl_easy.setopt_slist (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_httpheader, p)
			curl.global_cleanup

			curl_easy.set_read_function (curl_handle)
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string.object_id)

			debug ("twitter")
				print ("TWITTER: " + l_url + "%N")
			end
			l_result := curl_easy.perform (curl_handle)

			http_status := curl_easy.getinfo (curl_handle, {CURL_INFO_CONSTANTS}.curlinfo_response_code)
			http_status := l_result

			last_api_call := l_url
			curl_easy.cleanup (curl_handle)
			Result := l_curl_string.string
		end

feature {NONE} -- Implementation

	urlencode (s: STRING): STRING
		do
			Result := s.string
			Result.replace_substring_all ("#", "%%23")
			Result.replace_substring_all ("%T", "%%09")
			Result.replace_substring_all (" ", "%%20")
			Result.replace_substring_all ("/", "%%2F")
			Result.replace_substring_all ("&", "%%26")
			Result.replace_substring_all ("<", "%%3C")
			Result.replace_substring_all ("=", "%%3D")
			Result.replace_substring_all (">", "%%3E")
			Result.replace_substring_all ("%"", "%%22")
			Result.replace_substring_all ("%'", "%%27")
		end

	urldecode (s: STRING): STRING
		do
			Result := s.string
			Result.replace_substring_all ("%%23", "#")
			Result.replace_substring_all ("%%20", " ")
			Result.replace_substring_all ("%%09", "%T")
			Result.replace_substring_all ("%%2F", "/")
			Result.replace_substring_all ("%%26", "&")
			Result.replace_substring_all ("%%3C", "<")
			Result.replace_substring_all ("%%3D", "=")
			Result.replace_substring_all ("%%3E", ">")
			Result.replace_substring_all ("%%22", "%"")
			Result.replace_substring_all ("%%27", "%'")
			to_implement ("not yet implemented")
		end

	stripslashes (s: STRING): STRING
		do
			Result := s.string
			Result.replace_substring_all ("\\%"", "\%"")
			Result.replace_substring_all ("\\'", "\'")
			Result.replace_substring_all ("\\\\'", "\\")
		end

	curl: CURL_EXTERNALS is
			-- cURL externals
		once
			create Result
		end

	curl_easy: CURL_EASY_EXTERNALS
			-- cURL easy externals
		once
			create Result
		end

	curl_handle: POINTER;
			-- cURL handle

feature {NONE} -- Constants

	json_id: STRING = "json"

	xml_id: STRING = "xml"

	rss_id: STRING = "rss"

	atom_id: STRING = "atom"

end
