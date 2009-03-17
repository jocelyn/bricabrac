note
	description: "Summary description for {TWITTER_I}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TWITTER_I

inherit
	REFACTORING_HELPER

--create
--	make,
--	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: STRING)
		deferred
		end

	make_with_source (a_username, a_password: STRING; a_source: STRING)
		deferred
		end

feature -- Twitter: Status Methods

	public_timeline: detachable LIST [TWITTER_STATUS]
			--Returns the 20 most recent statuses from non-protected users who have set a custom user icon.  Does not require authentication.  Note that the public timeline is cached for 60 seconds so requesting it more often than that is a waste of resources.
			--URL: http://twitter.com/statuses/public_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--API limit: Not applicable
			--Returns: list of status elements		
		do
			to_implement ("not yet supported")
		end

	friends_timeline (a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): detachable LIST [TWITTER_STATUS]
			--Returns the 20 most recent statuses posted by the authenticating user and that user's friends. This is the equivalent of /home on the Web.
			--URL: http://twitter.com/statuses/friends_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--API Limit: 1 per request
			--Parameters:
			--    * since.  Optional.
			--		Narrows the returned results to just those statuses created after the specified HTTP-formatted date, up to 24 hours old.
			--		The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/friends_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.
			--		Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/friends_timeline.xml?since_id=12345
			--    * count.  Optional.
			--		Specifies the number of statuses to retrieve. May not be greater than 200.  Ex: http://twitter.com/statuses/friends_timeline.xml?count=5
			--    * page. Optional.
			--		Ex: http://twitter.com/statuses/friends_timeline.rss?page=3
			--Returns: list of status elements
		do
			to_implement ("not yet supported")
		end

	user_timeline (a_id: INTEGER; a_screen_name: detachable STRING; a_since_date: detachable STRING; a_since_id: INTEGER; a_count, a_page: INTEGER): detachable LIST [TWITTER_STATUS]
			--Returns the 20 most recent statuses posted from the authenticating user. It's also possible to request another user's timeline via the id parameter below. This is the equivalent of the Web /archive page for your own user, or the profile page for a third party.
			--URL: http://twitter.com/statuses/user_timeline.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  Specifies the ID or screen name of the user for whom to return the friends_timeline.
			--		 Ex: http://twitter.com/statuses/user_timeline/12345.xml or http://twitter.com/statuses/user_timeline/bob.json.
			--    * count.  Optional.  Specifies the number of statuses to retrieve. May not be greater than 200.  Ex: http://twitter.com/statuses/user_timeline.xml?count=5
			--    * since.  Optional.  Narrows the returned results to just those statuses created after the specified HTTP-formatted date, up to 24 hours old.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/user_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/user_timeline.xml?since_id=12345
			--    * page. Optional. Ex: http://twitter.com/statuses/user_timeline.rss?page=3
			--Returns: list of status elements		
		do
			to_implement ("not yet supported")
		end

	show_status (a_id: INTEGER): detachable TWITTER_STATUS
			-- single status, specified by the id parameter below.
			-- The status's author will be returned inline.
		deferred
		end

	update_status (a_status: STRING; in_reply_to_status_id: INTEGER): detachable TWITTER_STATUS
			-- Updates the authenticating user's status.
		require
			a_status_valid: a_status /= Void and then a_status.count <= 140
		deferred
		end

	replies (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_STATUS]
			--Returns the 20 most recent @replies (status updates prefixed with @username) for the authenticating user.
			--URL: http://twitter.com/statuses/replies.format
			--Formats: xml, json, rss, atom
			--Method(s): GET
			--Parameters:
			--    * page.  Optional. Retrieves the 20 next most recent replies.  Ex: http://twitter.com/statuses/replies.xml?page=3
			--    * since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date, up to 24 hours old.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/replies.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
			--    * since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/replies.xml?since_id=12345
			--Returns: list of status elements		
		do
			to_implement ("not yet supported")
		end

	destroy (a_id: INTEGER): detachable TWITTER_STATUS
			--Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
			--URL: http://twitter.com/statuses/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the status to destroy.  Ex: http://twitter.com/statuses/destroy/12345.json or http://twitter.com/statuses/destroy/23456.xml
			--Returns: status element		
		require
			a_id_required: a_id > 0
		do
			to_implement ("not yet supported")
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
		deferred
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
		deferred
		end

	end_session
			--Ends the session of the authenticating user, returning a null cookie.
			--Use this method to sign users out of client-facing applications like widgets.
			--URL: http://twitter.com/account/end_session.format
			--Formats: xml, json
			--Method(s): POST
		deferred
		end

	rate_limit_status: detachable TUPLE [ reset_time_in_seconds: INTEGER; remaining_hits: INTEGER; hourly_limit: INTEGER; reset_time: detachable STRING]
			-- Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour. Calls to rate_limit_status do not count against the rate limit.  If authentication credentials are provided, the rate limit status for the authenticating user is returned.  Otherwise, the rate limit status for the requester's IP address is returned.
			-- URL: http://twitter.com/account/rate_limit_status.format
			-- Formats: xml, json
			-- Method(s): GET
			-- Parameters: none
			-- Ex:{"reset_time_in_seconds":1237292716,"remaining_hits":100,"hourly_limit":100,"reset_time":"Tue Mar 17 12:25:16 +0000 2009"}			
		deferred
		end

end
