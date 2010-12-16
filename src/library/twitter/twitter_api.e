note
	description: "Summary description for {TWITTER}."
	author: "Jocelyn Fiat"
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

	make (a_username, a_password: detachable STRING)
		do
			if a_username /= Void and a_password /= Void then
				username := a_username.string
				password := a_password.string
				credentials := a_username + ":" + a_password
			end
			application_source := Void

			format := json_id
		end

	make_with_source (a_username, a_password: detachable STRING; a_source: like application_source)
		do
			make (a_username, a_password)
			set_application_source (a_source)
		end

feature -- Access

	username: detachable STRING
	password: detachable STRING
	credentials: detachable STRING
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
			-- Format is `xml'
		do
			Result := format = xml_id
		end

	format_is_json: BOOLEAN
			-- Format is `json'	
		do
			Result := format = json_id
		end

	format_is_rss: BOOLEAN
				-- Format is `rss'
		do
			Result := format = rss_id
		end

	format_is_atom: BOOLEAN
				-- Format is `atom'
		do
			Result := format = atom_id
		end

feature -- Element change

	set_json_format
			-- Set format to `json'
		do
			format := json_id
		end

	set_xml_format
			-- Set format to `xml'	
		do
			format := xml_id
		end

	set_rss_format
			-- Set format to `rss'	
		do
			format := rss_id
		end

	set_atom_format
			-- Set format to `atom'	
		do
			format := atom_id
		end

	set_application_source (a_source: like application_source)
		do
			if a_source /= Void then
				application_source := urlencode (a_source)
			else
				application_source := Void
			end
		end

feature -- Twitter: Status Methods

	public_timeline: like api_get_call
			--Returns the 20 most recent statuses from non-protected users who have set a custom user icon.
			--	Does not require authentication.
			--	Note that the public timeline is cached for 60 seconds so requesting it more often than that is a waste of resources.
			--URL: http://twitter.com/statuses/public_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--API limit: Not applicable
			--Returns: list of status elements	
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("statuses/public_timeline." + format, Void)
			Result := api_get_call (l_api_call, False)
		end

	friends_timeline (a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): like api_get_auth_call
			--Returns the 20 most recent statuses posted by the authenticating user and that user's friends. This is the equivalent of /home on the Web.
			--URL: http://twitter.com/statuses/friends_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--API Limit: 1 per request
			--Parameters:
			--    * since.  Optional.
			--		Narrows the returned results to just those statuses created after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting an If-Modified-Since header in your HTTP request.
			--		Ex: http://twitter.com/statuses/friends_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.
			--		Returns only statuses with an ID greater than (that is, more recent than) the specified ID.
			--		Ex: http://twitter.com/statuses/friends_timeline.xml?since_id=12345
			--    * count.  Optional.
			--		Specifies the number of statuses to retrieve. May not be greater than 200.
			--		Ex: http://twitter.com/statuses/friends_timeline.xml?count=5
			--    * page. Optional.
			--		Ex: http://twitter.com/statuses/friends_timeline.rss?page=3
			--Returns: list of status elements
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("statuses/friends_timeline." + format, Void)
			if a_since_date /= Void then
				append_parameters_to_url (l_api_call, <<["since", a_since_date]>>)
			end
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			if a_count > 0 then
				append_parameters_to_url (l_api_call, <<["count", a_count.out]>>)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	user_timeline (a_id: INTEGER; a_screen_name: detachable STRING; a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): like api_get_auth_call
			--Returns the 20 most recent statuses posted from the authenticating user.
			-- It's also possible to request another user's timeline via the id parameter below.
			-- This is the equivalent of the Web /archive page for your own user, or the profile page for a third party.
			--URL: http://twitter.com/statuses/user_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  Specifies the ID or screen name of the user for whom to return the friends_timeline.
			--		 Ex: http://twitter.com/statuses/user_timeline/12345.xml or http://twitter.com/statuses/user_timeline/bob.json.
			--    * count.  Optional.  Specifies the number of statuses to retrieve. May not be greater than 200.
			--		Ex: http://twitter.com/statuses/user_timeline.xml?count=5
			--    * since.  Optional.  Narrows the returned results to just those statuses
			--		created after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting an If-Modified-Since header in your HTTP request.
			--		Ex: http://twitter.com/statuses/user_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.
			--		Ex: http://twitter.com/statuses/user_timeline.xml?since_id=12345
			--    * page. Optional. Ex: http://twitter.com/statuses/user_timeline.rss?page=3
			--Returns: list of status elements		
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("statuses/user_timeline/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("statuses/user_timeline/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("statuses/user_timeline." + format, Void)
			end

			if a_since_date /= Void then
				append_parameters_to_url (l_api_call, <<["since", a_since_date]>>)
			end
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			if a_count > 0 then
				append_parameters_to_url (l_api_call, <<["count", a_count.out]>>)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	show_status (a_id: INTEGER): like api_get_call
			-- Returns a single status, specified by the id parameter below.  The status's author will be returned inline.
			-- URL: http://twitter.com/statuses/show/id.format
			-- Formats: xml, json
			-- Method(s): GET
			-- Parameters:
			--     * id.  Required.  The numerical ID of the status you're trying to retrieve.
			--			Ex: http://twitter.com/statuses/show/123.xml
			-- Returns: status element
		require
			valid_format: format_is_xml or format_is_json
			a_id_required: a_id > 0
		do
			Result := api_get_call (twitter_url ("statuses/show/" + a_id.out + "." + format, Void), False)
		end

	update_status (a_status: STRING; a_in_reply_to_status_id: INTEGER): like api_post_auth_call
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
			valid_format: format_is_xml or format_is_json
			a_status_required: a_status /= Void and then a_status.count <= 140
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
			Result := api_post_auth_call (l_api_call)
		end

	replies (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): like api_get_auth_call
			--Returns the 20 most recent @replies (status updates prefixed with @username) for the authenticating user.
			--URL: http://twitter.com/statuses/replies.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * page.  Optional. Retrieves the 20 next most recent replies.  Ex: http://twitter.com/statuses/replies.xml?page=3
			--    * since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting an If-Modified-Since header in your HTTP request.
			--		Ex: http://twitter.com/statuses/replies.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.
			--		Ex: http://twitter.com/statuses/replies.xml?since_id=12345
			--Returns: list of status elements		
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("statuses/replies." + format, Void)
			if a_since_date /= Void then
				append_parameters_to_url (l_api_call, <<["since", a_since_date]>>)
			end
			if a_since_id > 0 then
				append_parameters_to_url (l_api_call, <<["since_id", a_since_id.out]>>)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	destroy_status (a_id: INTEGER): like api_post_auth_call
			--Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
			--URL: http://twitter.com/statuses/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the status to destroy.  Ex: http://twitter.com/statuses/destroy/12345.json or http://twitter.com/statuses/destroy/23456.xml
			--Returns: status element		
		require
			valid_format: format_is_xml or format_is_json
			a_id_required: a_id > 0
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("statuses/destroy/" + a_id.out + "." + format, Void)
			Result := api_post_auth_call (l_api_call)
		end

feature -- Twitter: User Methods

	friends (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): like api_get_auth_call
			--Returns the authenticating user's friends, each with current status inlinapi_get_calle. They are ordered by the order in which they were added as friends. It's also possible to request another user's recent friends list via the id parameter below.
			-- URL: http://twitter.com/statuses/friends.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen name of the user for whom to request a list of friends.
			--		Ex: http://twitter.com/statuses/friends/12345.json or http://twitter.com/statuses/friends/bob.xml
			--    * page.  Optional. Retrieves the next 100 friends.
			--		Ex: http://twitter.com/statuses/friends.xml?page=2
			--Returns: list of basic user information elements
		require
			valid_format: format_is_xml or format_is_json
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("statuses/friends/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("statuses/friends/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("statuses/friends." + format, Void)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	followers (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): like api_get_auth_call
			--Returns the authenticating user's followers, each with current status inline.  They are ordered by the order in which they joined Twitter (this is going to be changed).
			--URL: http://twitter.com/statuses/followers.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen name of the user for whom to request a list of followers.
			--		Ex: http://twitter.com/statuses/followers/12345.json or http://twitter.com/statuses/followers/bob.xml
			--    * page.  Optional. Retrieves the next 100 followers.
			--		Ex: http://twitter.com/statuses/followers.xml?page=2
			--Returns: list of basic user information elements	
		require
			valid_format: format_is_xml or format_is_json
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("statuses/followers/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("statuses/followers/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("statuses/followers." + format, Void)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	show_user (a_id: INTEGER; a_screen_name: detachable STRING): like api_get_auth_call
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
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
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
				Result := api_get_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

feature -- Twitter: Direct Message Methods

	direct_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): like api_get_auth_call
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
			Result := api_get_auth_call (l_api_call)
		end

	sent_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): like api_get_auth_call
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
		require
			valid_format: format_is_xml or format_is_json
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
			Result := api_get_auth_call (l_api_call)
		end

	new_message (a_user: STRING; a_text: STRING): like api_post_auth_call
			--Sends a new direct message to the specified user from the authenticating user.  Requires both the user and text parameters below.  Request must be a POST.  Returns the sent message in the requested format when successful.
			--URL: http://twitter.com/direct_messages/new.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * user.  Required.  The ID or screen name of the recipient user.
			--    * text.  Required.  The text of your direct message.  Be sure to URL encode as necessary, and keep it under 140 characters.
			--Return: direct message element
		require
			valid_format: format_is_xml or format_is_json
			a_user_required: a_user /= Void
			a_text_required: a_text /= Void and then a_text.count <= 140
		local
			l_text: STRING
			l_api_call: STRING
		do
			l_text := urlencode( stripslashes (urldecode (a_text)))
			check l_text.count <= 140 end

			l_api_call := twitter_url ("direct_messages/new." + format, <<["user", a_user], ["text", l_text]>>)
			Result := api_post_auth_call (l_api_call)
		end

	destroy_message (a_id: INTEGER): like api_post_auth_call
			--Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.
			--URL: http://twitter.com/direct_messages/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the direct message to destroy.  Ex: http://twitter.com/direct_messages/destroy/12345.json or http://twitter.com/direct_messages/destroy/23456.xml
			--Return: list of direct message elements		
		require
			a_id_required: a_id > 0
			valid_format: format_is_xml or format_is_json
		do
			Result := api_post_auth_call (twitter_url ("direct_messages/destroy/" + a_id.out + "." + format, Void))
		end

feature -- Twitter: Friendship Methods

	create_friendship (a_id: INTEGER; a_screen_name: detachable STRING; a_follow: BOOLEAN): like api_post_auth_call
			--Befriends the user specified in the ID parameter as the authenticating user.  Returns the befriended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
			--URL: http://twitter.com/friendships/create/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user to befriend.
			--		Ex: http://twitter.com/friendships/create/12345.json or http://twitter.com/friendships/create/bob.xml
			--    * follow.  Optional.  Enable notifications for the target user in addition to becoming friends.
			--	Ex:  http://twitter.com/friendships/create/bob.json?follow=true
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("friendships/create/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("friendships/create/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				if a_follow then
					append_parameters_to_url (l_api_call, <<["follow", "true"]>>)
				end
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

	destroy_friendship (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Discontinues friendship with the user specified in the ID parameter as the authenticating user.  Returns the un-friended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
			--URL: http://twitter.com/friendships/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user with whom to discontinue friendship.
			--		Ex: http://twitter.com/friendships/destroy/12345.json or http://twitter.com/friendships/destroy/bob.xml
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("friendships/destroy/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("friendships/destroy/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

	friendship_exists (a_id: INTEGER; a_screen_name: detachable STRING;
					b_id: INTEGER; b_screen_name: detachable STRING): like api_get_auth_call
			--Tests if a friendship exists between two users.
			--URL: http://twitter.com/friendships/exists.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * user_a.  Required.  The ID or screen_name of the first user to test friendship for.
			--    * user_b.  Required.  The ID or screen_name of the second user to test friendship for.
			--    * Ex: http://twitter.com/friendships/exists.xml?user_a=alice&user_b=bob
			--Returns: true, false
		require
			valid_format: format_is_xml or format_is_json
			user_a_required: a_id > 0 or a_screen_name /= Void
			user_b_required: b_id > 0 or b_screen_name /= Void
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("friendships/exists." + format, Void)
			if a_id > 0 then
				append_parameters_to_url (l_api_call, <<["user_a", a_id.out]>>)
			elseif a_screen_name /= Void then
				append_parameters_to_url (l_api_call, <<["user_a", a_screen_name]>>)
			else
				check False end
			end

			if b_id > 0 then
				append_parameters_to_url (l_api_call, <<["user_b", b_id.out]>>)
			elseif b_screen_name /= Void then
				append_parameters_to_url (l_api_call, <<["user_b", b_screen_name]>>)
			else
				check False end
			end
			Result := api_get_auth_call (l_api_call)
		end

feature -- Twitter: Social Graph Methods

	friends_ids (a_id: INTEGER; a_screen_name: detachable STRING): like api_get_auth_call
			--Returns an array of numeric IDs for every user the specified user is following.
			--URL: http://twitter.com/friends/ids.xml
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.
			--	Ex: http://twitter.com/friends/ids/bob.xml
			--Returns: list of IDs
		require
			valid_format: format_is_xml or format_is_json
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("friends/ids/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("friends/ids/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("friends/ids." + format, Void)
			end
			Result := api_get_auth_call (l_api_call)
		end

	followers_ids (a_id: INTEGER; a_screen_name: detachable STRING): like api_get_auth_call
			--Returns an array of numeric IDs for every user the specified user is followed by.
			--URL: http://twitter.com/followers/ids.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.
			--	Ex: http://twitter.com/followers/ids/bob.xml
			--Returns: list of IDs
		require
			valid_format: format_is_xml or format_is_json
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("followers/ids/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("followers/ids/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("followers/ids." + format, Void)
			end
			Result := api_get_auth_call (l_api_call)
		end

feature -- Twitter: Account Methods

	verify_credentials: like api_get_auth_call
			--Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not.  Use this method to test if supplied user credentials are valid.
			--URL: http://twitter.com/account/verify_credentials.format
			--Formats: xml, json
			--Method(s): GET
			--Returns: extended user information element
		require
			valid_format: format_is_xml or format_is_json
		do
			Result := api_get_auth_call (twitter_url ("account/verify_credentials." + format, Void))
		end

	end_session: like api_post_auth_call
			--Ends the session of the authenticating user, returning a null cookie.  Use this method to sign users out of client-facing applications like widgets.
			--URL: http://twitter.com/account/end_session.format
			--Formats: xml, json
			--Method(s): POST
		require
			valid_format: format_is_xml or format_is_json
		do
			Result := api_post_auth_call (twitter_url ("account/end_session." + format, Void))
		end

	update_location (a_location: STRING): like update_profile
		obsolete "use update_profile"
		do
			Result := update_profile (Void, Void, Void, a_location, Void)
		end

	update_delivery_device (a_device: STRING): like api_post_auth_call
			--update_delivery_device
			--Sets which device Twitter delivers updates to for the authenticating user.  Sending none as the device parameter will disable IM or SMS updates.
			--URL: http://twitter.com/account/update_delivery_device.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * device.  Required.  Must be one of: sms, im, none.
			--		Ex: http://twitter.com/account/update_delivery_device.xml?device=im
			--Returns: basic user information element		
		require
			valid_format: format_is_xml or format_is_json
			device_required: a_device /= Void
			valid_device: a_device.is_case_insensitive_equal ("sms")
							or a_device.is_case_insensitive_equal ("im")
							or a_device.is_case_insensitive_equal ("none")
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("account/update_delivery_device." + format, <<["device", a_device]>>)
			Result := api_post_auth_call (l_api_call)
		end

	update_profile (a_name, a_email, a_url, a_location, a_description: detachable STRING): like api_post_auth_call
			--Sets values that users are able to set under the "Account" tab of their settings page. Only the parameters specified will be updated; to only update the "name" attribute, for example, only include that parameter in your request.
			--URL: http://twitter.com/account/update_profile.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters: one or more of the following parameters must be present.  Each parameter's value should be a string.  See the individual parameter descriptions below for further constraints.
			--    * name.  Optional. Maximum of 20 characters.
			--    * email.  Optional. Maximum of 40 characters. Must be a valid email address.
			--    * url.  Optional. Maximum of 100 characters. Will be prepended with "http://" if not present.
			--    * location.  Optional. Maximum of 30 characters. The contents are not normalized or geocoded in any way.
			--    * description.  Optional. Maximum of 160 characters.
			--Returns: extended user information element
		require
			valid_format: format_is_xml or format_is_json
			valid_name: a_name /= Void implies a_name.count <= 20
			valid_email: a_email /= Void implies a_email.count <= 40
			valid_url: a_url /= Void implies a_url.count <= 100
			valid_location: a_location /= Void implies a_location.count <= 30
			valid_description: a_description /= Void implies a_description.count <= 160
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
			Result := api_post_auth_call (l_api_call)
		end

	update_profile_colors (a_profile_background_color, a_profile_text_color, a_profile_link_color,
					a_profile_sidebar_fill_color, a_profile_sidebar_border_color: detachable STRING): like api_post_auth_call
			--Sets one or more hex values that control the color scheme of the authenticating user's profile page on twitter.com.  These values are also returned in the /users/show API method.
			--URL: http://twitter.com/account/update_profile_colors.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters: one or more of the following parameters must be present.
			--	Each parameter's value must be a valid hexidecimal value, and may be either three or six characters (ex: #fff or #ffffff).
			--    * profile_background_color.  Optional.
			--    * profile_text_color.  Optional.
			--    * profile_link_color.  Optional.
			--    * profile_sidebar_fill_color.  Optional.
			--    * profile_sidebar_border_color.  Optional.
			--Returns: extended user information element
		require
			valid_format: format_is_xml or format_is_json
		local
			l_api_call: STRING
		do
			l_api_call := twitter_url ("account/update_profile_colors." + format, Void)
			if a_profile_background_color /= Void then
				append_parameters_to_url (l_api_call, <<["profile_background_color", a_profile_background_color]>>)
			end
			if a_profile_text_color /= Void then
				append_parameters_to_url (l_api_call, <<["profile_text_color", a_profile_text_color]>>)
			end
			if a_profile_link_color /= Void then
				append_parameters_to_url (l_api_call, <<["profile_link_color", a_profile_link_color]>>)
			end

			if a_profile_sidebar_fill_color /= Void then
				append_parameters_to_url (l_api_call, <<["profile_sidebar_fill_color", a_profile_sidebar_fill_color]>>)
			end
			if a_profile_sidebar_border_color /= Void then
				append_parameters_to_url (l_api_call, <<["profile_sidebar_border_color", a_profile_sidebar_border_color]>>)
			end

			Result := api_post_auth_call (l_api_call)
		end

	update_profile_image (a_image: STRING): like api_post_auth_call
			--Updates the authenticating user's profile image.  Expects raw multipart data, not a URL to an image.
			--URL: http://twitter.com/account/update_profile_image.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 700 kilobytes in size.
			--		Images with width larger than 500 pixels will be scaled down.
			--Returns: extended user information element
		require
			valid_format: format_is_xml or format_is_json
			a_image_required: a_image /= Void
		do
			to_implement ("FIXME")
			Result := "FIXME"
		end

	update_profile_background_image (a_image: STRING): like api_post_auth_call
			--Updates the authenticating user's profile background image.  Expects raw multipart data, not a URL to an image.
			--URL: http://twitter.com/account/update_profile_background_image.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 800 kilobytes in size.  Images with width larger than 2048 pixels will be scaled down.
			--Returns: extended user information element
		require
			valid_format: format_is_xml or format_is_json
			a_image_required: a_image /= Void
		do
			to_implement ("FIXME")
			Result := "FIXME"
		end

	rate_limit_status (a_credentials_provided: BOOLEAN): like api_get_call
			--rate_limit_status
			--Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour.
			--Calls to rate_limit_status do not count against the rate limit.
			--If authentication credentials are provided `a_credentials_provided', the rate limit status for the authenticating user is returned.
			--Otherwise, the rate limit status for the requester's IP address is returned.
			--URL: http://twitter.com/account/rate_limit_status.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters: none
		require
			valid_format: format_is_xml or format_is_json
		do
			Result := api_get_call (twitter_url ("account/rate_limit_status." + format, Void), a_credentials_provided)
		end

feature -- Twitter: favorite Methods

	favorites (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): like api_get_auth_call
			--Returns the 20 most recent favorite statuses for the authenticating user or user specified by the ID parameter in the requested format.
			--URL: http://twitter.com/favorites.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen name of the user for whom to request a list of favorite statuses.
			--		Ex: http://twitter.com/favorites/bob.json or http://twitter.com/favorites/bob.rss
			--    * page.  Optional. Retrieves the 20 next most recent favorite statuses.
			--		Ex: http://twitter.com/favorites.xml?page=3
			--Returns: list of status elements	
		local
			l_api_call: STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("favorites/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("favorites/" + a_screen_name.out + "." + format, Void)
			else
				l_api_call := twitter_url ("favorites." + format, Void)
			end
			if a_page > 0 then
				append_parameters_to_url (l_api_call, <<["page", a_page.out]>>)
			end
			Result := api_get_auth_call (l_api_call)
		end

	create_favorite (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Favorites the status specified in the ID parameter as the authenticating user.  Returns the favorite status when successful.
			--URL: http://twitter.com/favorites/create/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID of the status to favorite.
			--		Ex: http://twitter.com/favorites/create/12345.json or http://twitter.com/favorites/create/45567.xml
			--Returns: status element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("favorites/create/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("favorites/create/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

	destroy_favorite (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Favorites the status specified in the ID parameter as the authenticating user.  Returns the favorite status when successful.
			--URL: http://twitter.com/favorites/destroy/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID of the status to favorite.
			--		Ex: http://twitter.com/favorites/destroy/12345.json or http://twitter.com/favorites/destroy/45567.xml
			--Returns: status element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("favorites/destroy/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("favorites/destroy/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

feature -- Twitter: Notification Methods

	follow (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Enables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
			--URL:http://twitter.com/notifications/follow/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user to follow.
			--		Ex: http://twitter.com/notifications/follow/12345.xml or http://twitter.com/notifications/follow/bob.json
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("notifications/follow/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("notifications/follow/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

	leave (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Disables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
			--URL: http://twitter.com/notifications/leave/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user to leave.
			--		Ex:  http://twitter.com/notifications/leave/12345.xml or http://twitter.com/notifications/leave/bob.json
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("notifications/leave/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("notifications/leave/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end


feature -- Twitter: Block Methods

	create_block (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Blocks the user specified in the ID parameter as the authenticating user.  Returns the blocked user in the requested format when successful.  You can find out more about blocking in the Twitter Support Knowledge Base.
			--URL: http://twitter.com/blocks/create/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen_name of the user to block.  Ex: http://twitter.com/blocks/create/12345.json or http://twitter.com/blocks/create/bob.xml
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("blocks/create/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("blocks/create/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

	destroy_block (a_id: INTEGER; a_screen_name: detachable STRING): like api_post_auth_call
			--Un-blocks the user specified in the ID parameter as the authenticating user.  Returns the un-blocked user in the requested format when successful.
			--URL: http://twitter.com/blocks/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID or screen_name of the user to un-block.  Ex: http://twitter.com/blocks/destroy/12345.json or http://twitter.com/blocks/destroy/bob.xml
			--Returns: basic user information element
		require
			valid_format: format_is_xml or format_is_json
			id_required: a_id > 0 or a_screen_name /= Void
		local
			l_api_call: detachable STRING
		do
			if a_id > 0 then
				l_api_call := twitter_url ("blocks/destroy/" + a_id.out + "." + format, Void)
			elseif a_screen_name /= Void then
				l_api_call := twitter_url ("blocks/destroy/" + a_screen_name.out + "." + format, Void)
			else
				check False end
			end
			if l_api_call /= Void then
				Result := api_post_auth_call (l_api_call)
			else
				create Result.make_empty
			end
		end

feature -- Twitter: Help Methods

	test: like api_get_auth_call
			--Returns the string "ok" in the requested format with a 200 OK HTTP status code.			
			-- URL: http://twitter.com/help/test.format
			--Formats: xml, json
			--Method(s): GET
		require
			valid_format: format_is_xml or format_is_json
		do
			Result := api_get_auth_call (twitter_url ("help/test." + format, Void))
		end

feature {NONE} -- Implementation

	twitter_url (a_query: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]]): STRING
			-- Twitter url for `a_query' and `a_parameters'
		require
			a_query_attached: a_query /= Void
		do
			Result := url ("http://twitter.com/" + a_query, a_parameters)
		ensure
			Result_attached: Result /= Void
		end

	url (a_base_url: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]]): STRING
			-- url for `a_base_url' and `a_parameters'
		require
			a_base_url_attached: a_base_url /= Void
		do
			create Result.make_from_string (a_base_url)
			append_parameters_to_url (Result, a_parameters)
		end

	append_parameters_to_url (a_url: STRING; a_parameters: detachable ARRAY [detachable TUPLE [name: STRING; value: STRING]])
			-- Append parameters `a_parameters' to `a_url'
		require
			a_url_attached: a_url /= Void
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

	api_get_auth_call (a_api_url: STRING): like internal_api_call
			-- GET REST API call for `a_api_url'
			-- credential required
		do
			Result := internal_api_call (a_api_url, True, False)
		end

	api_get_call (a_api_url: STRING; a_credentials: BOOLEAN): like internal_api_call
			-- GET REST API call for `a_api_url'
			-- if `a_credentials' provides credentials
		do
			Result := internal_api_call (a_api_url, a_credentials, False)
		end

	api_post_auth_call (a_api_url: STRING): like internal_api_call
			-- POST REST API call for `a_api_url'
			-- credential required
		do
			Result := internal_api_call (a_api_url, True, True)
		end

	api_post_call (a_api_url: STRING; a_credentials: BOOLEAN): like internal_api_call
			-- POST REST API call for `a_api_url'
			-- if `a_credentials' provides credentials
		do
			Result := internal_api_call (a_api_url, a_credentials, True)
		end

	internal_api_call (a_api_url: STRING; a_require_credentials: BOOLEAN; a_http_post: BOOLEAN): STRING
			-- REST API call for `a_api_url' with `a_require_credentials' and `a_http_post'
		local
			l_app_src: detachable STRING
			l_result: INTEGER
			l_curl_string: CURL_STRING
			l_url: STRING
			p: POINTER
			a_data: CELL [detachable ANY]
		do
			l_url := a_api_url.string
			l_app_src := application_source
			if l_app_src /= Void then
				append_parameters_to_url (l_url, <<["source", l_app_src]>>)
			end

			curl_handle := curl_easy.init

			curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_url, l_url)
			if a_require_credentials then
				if attached credentials as l_credentials then
					curl_easy.setopt_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_userpwd, l_credentials)
				else
					check credentials_attached: False end
				end
			end
			if a_http_post then
				curl_easy.setopt_integer (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_post, 1)
			end

			curl.global_init
			p := curl.slist_append (p, "Expect:")
			curl_easy.setopt_slist (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_httpheader, p)
			curl.global_cleanup

			curl_easy.set_read_function (curl_handle)
			curl_easy.set_write_function (curl_handle)
			create l_curl_string.make_empty
			curl_easy.setopt_curl_string (curl_handle, {CURL_OPT_CONSTANTS}.curlopt_writedata, l_curl_string)

			debug ("twitter")
				io.put_string ("TWITTER: " + l_url)
				io.put_new_line
			end
			l_result := curl_easy.perform (curl_handle)

			create a_data.put (Void)
			l_result := curl_easy.getinfo (curl_handle, {CURL_INFO_CONSTANTS}.curlinfo_response_code, a_data)
			if l_result = 0 and then attached {INTEGER} a_data.item as l_http_status then
				http_status := l_http_status
			else
				http_status := 0
			end

			last_api_call := l_url
			curl_easy.cleanup (curl_handle)
			Result := l_curl_string.string
		end

feature -- Access: Encoding

	urlencode (s: STRING): STRING
			-- URL encode `s'
		do
			Result := s.string
			Result.replace_substring_all ("#", "%%23")
			Result.replace_substring_all (" ", "%%20")
			Result.replace_substring_all ("%T", "%%09")
			Result.replace_substring_all ("%N", "%%0A")
			Result.replace_substring_all ("/", "%%2F")
			Result.replace_substring_all ("&", "%%26")
			Result.replace_substring_all ("<", "%%3C")
			Result.replace_substring_all ("=", "%%3D")
			Result.replace_substring_all (">", "%%3E")
			Result.replace_substring_all ("%"", "%%22")
			Result.replace_substring_all ("%'", "%%27")
		end

	urldecode (s: STRING): STRING
			-- URL decode `s'
		do
			Result := s.string
			Result.replace_substring_all ("%%23", "#")
			Result.replace_substring_all ("%%20", " ")
			Result.replace_substring_all ("%%09", "%T")
			Result.replace_substring_all ("%%0A", "%N")
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
			Result.replace_substring_all ("\%"", "%"")
			Result.replace_substring_all ("\'", "'")
			Result.replace_substring_all ("\/", "/")
			Result.replace_substring_all ("\\", "\")
		end

feature {NONE} -- Implementation

	curl: CURL_EXTERNALS
			-- cURL externals
		once
			create Result
		end

	curl_easy: CURL_EASY_EXTERNALS
			-- cURL easy externals
		once
			create Result
		end

	curl_handle: POINTER
			-- cURL handle

feature {NONE} -- Constants

	json_id: STRING = "json"

	xml_id: STRING = "xml"

	rss_id: STRING = "rss"

	atom_id: STRING = "atom"

note
	copyright: "Copyright (c) 2003-2009, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
