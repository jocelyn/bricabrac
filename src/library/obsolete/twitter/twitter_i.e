note
	description: "Summary description for {TWITTER_I}."
	author: "Jocelyn Fiat"
	date: "$Date: 2009-04-02 21:16:39 +0200 (Thu, 02 Apr 2009) $"
	revision: "$Revision: 24 $"

deferred class
	TWITTER_I

inherit
	REFACTORING_HELPER

--create
--	make,
--	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: detachable STRING)
		deferred
		end

	make_with_source (a_username, a_password: detachable STRING; a_source: STRING)
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
		deferred
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
		deferred
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
		deferred
		end

	status (a_id: INTEGER): detachable TWITTER_STATUS
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
		deferred
		end

	destroy_status (a_id: INTEGER): detachable TWITTER_STATUS
			--Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
			--URL: http://twitter.com/statuses/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the status to destroy.  Ex: http://twitter.com/statuses/destroy/12345.json or http://twitter.com/statuses/destroy/23456.xml
			--Returns: status element		
		require
			a_id_required: a_id > 0
		deferred
		end

feature -- Twitter: User Methods		

	friends (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_USER]
			--Returns the authenticating user's friends, each with current status inline. They are ordered by the order in which they were added as friends. It's also possible to request another user's recent friends list via the id parameter below.
			-- URL: http://twitter.com/statuses/friends.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen name of the user for whom to request a list of friends.
			--		Ex: http://twitter.com/statuses/friends/12345.json or http://twitter.com/statuses/friends/bob.xml
			--    * page.  Optional. Retrieves the next 100 friends.
			--		Ex: http://twitter.com/statuses/friends.xml?page=2
			--Returns: list of basic user information elements
		deferred
		end

	followers (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_USER]
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
		deferred
		end

	user (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
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

feature -- Twitter: Direct Message Methods

	direct_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_MESSAGE]
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
		deferred
		end

	sent_messages (a_since_date: detachable STRING; a_since_id: INTEGER; a_page: INTEGER): detachable LIST [TWITTER_MESSAGE]
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
		deferred
		end

	new_message (a_user: STRING; a_text: STRING): detachable TWITTER_MESSAGE
			--Sends a new direct message to the specified user from the authenticating user.  Requires both the user and text parameters below.  Request must be a POST.  Returns the sent message in the requested format when successful.
			--URL: http://twitter.com/direct_messages/new.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * user.  Required.  The ID or screen name of the recipient user.
			--    * text.  Required.  The text of your direct message.  Be sure to URL encode as necessary, and keep it under 140 characters.
			--Return: direct message element
		require
			a_user_required: a_user /= Void
			a_text_required: a_text /= Void and then a_text.count <= 140
		deferred
		end

	destroy_message (a_id: INTEGER): detachable LIST [TWITTER_MESSAGE]
			--Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.
			--URL: http://twitter.com/direct_messages/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID of the direct message to destroy.  Ex: http://twitter.com/direct_messages/destroy/12345.json or http://twitter.com/direct_messages/destroy/23456.xml
			--Return: list of direct message elements		
		require
			a_id_positive: a_id > 0
		deferred
		end

feature -- Twitter: Friendship Methods

	create_friendship (a_id: INTEGER; a_screen_name: detachable STRING; a_follow: BOOLEAN): detachable TWITTER_USER
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
		deferred
		end

	destroy_friendship (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Discontinues friendship with the user specified in the ID parameter as the authenticating user.  Returns the un-friended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
			--URL: http://twitter.com/friendships/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user with whom to discontinue friendship.
			--		Ex: http://twitter.com/friendships/destroy/12345.json or http://twitter.com/friendships/destroy/bob.xml
			--Returns: basic user information element
		deferred
		end

	friendship_exists (a_id: INTEGER; a_screen_name: detachable STRING;
					b_id: INTEGER; b_screen_name: detachable STRING): BOOLEAN
			--Tests if a friendship exists between two users.
			--URL: http://twitter.com/friendships/exists.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * user_a.  Required.  The ID or screen_name of the first user to test friendship for.
			--    * user_b.  Required.  The ID or screen_name of the second user to test friendship for.
			--    * Ex: http://twitter.com/friendships/exists.xml?user_a=alice&user_b=bob
			--Returns: true, false
		deferred
		end

feature -- Twitter: Social Graph Methods

	friends_ids (a_id: INTEGER; a_screen_name: detachable STRING): detachable LIST [INTEGER]
			--Returns an array of numeric IDs for every user the specified user is following.
			--URL: http://twitter.com/friends/ids.xml
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.
			--	Ex: http://twitter.com/friends/ids/bob.xml
			--Returns: list of IDs
		deferred
		end

	followers_ids (a_id: INTEGER; a_screen_name: detachable STRING): detachable LIST [INTEGER]
			--Returns an array of numeric IDs for every user the specified user is followed by.
			--URL: http://twitter.com/followers/ids.format
			--Formats: xml, json
			--Method(s): GET
			--Parameters:
			--    * id.  Optional.  The ID or screen_name of the user to retrieve the friends ID list for.
			--	Ex: http://twitter.com/followers/ids/bob.xml
			--Returns: list of IDs
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

	update_delivery_device (a_device: STRING): detachable TWITTER_USER
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
			valid_device: a_device.is_case_insensitive_equal ("sms")
							or a_device.is_case_insensitive_equal ("im")
							or a_device.is_case_insensitive_equal ("none")
		deferred
		end

	update_profile (a_name, a_email, a_url, a_location, a_description: detachable STRING): detachable TWITTER_USER
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
		deferred
		end

	update_profile_colors (a_profile_background_color, a_profile_text_color, a_profile_link_color,
					a_profile_sidebar_fill_color, a_profile_sidebar_border_color: detachable STRING): detachable TWITTER_USER
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
		deferred
		end

	update_profile_image (a_image: STRING): detachable TWITTER_USER
			--Updates the authenticating user's profile image.  Expects raw multipart data, not a URL to an image.
			--URL: http://twitter.com/account/update_profile_image.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 700 kilobytes in size.
			--		Images with width larger than 500 pixels will be scaled down.
			--Returns: extended user information element
		require
			a_image_required: a_image /= Void
		deferred
		end

	update_profile_background_image (a_image: STRING): detachable TWITTER_USER
			--Updates the authenticating user's profile background image.  Expects raw multipart data, not a URL to an image.
			--URL: http://twitter.com/account/update_profile_background_image.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * image.  Required.  Must be a valid GIF, JPG, or PNG image of less than 800 kilobytes in size.  Images with width larger than 2048 pixels will be scaled down.
			--Returns: extended user information element
		require
			a_image_required: a_image /= Void
		deferred
		end

	rate_limit_status (a_credentials_provided: BOOLEAN): detachable TUPLE [ reset_time_in_seconds: INTEGER; remaining_hits: INTEGER; hourly_limit: INTEGER; reset_time: detachable STRING]
			-- Returns the remaining number of API requests available to the requesting user before the API limit is reached for the current hour.
			-- Calls to rate_limit_status do not count against the rate limit.
			-- If authentication credentials are provided `a_credentials_provided',
			--	 the rate limit status for the authenticating user is returned.
			--   Otherwise, the rate limit status for the requester's IP address is returned.
			-- URL: http://twitter.com/account/rate_limit_status.format
			-- Formats: xml, json
			-- Method(s): GET
			-- Parameters: none
			-- Ex:{"reset_time_in_seconds":1237292716,"remaining_hits":100,"hourly_limit":100,"reset_time":"Tue Mar 17 12:25:16 +0000 2009"}			
		deferred
		end

feature -- Twitter: favorite Methods

	favorites (a_id: INTEGER; a_screen_name: detachable STRING; a_page: INTEGER): detachable LIST [TWITTER_STATUS]
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
		deferred
		end

	create_favorite (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_STATUS
			--Favorites the status specified in the ID parameter as the authenticating user.  Returns the favorite status when successful.
			--URL: http://twitter.com/favorites/create/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID of the status to favorite.
			--		Ex: http://twitter.com/favorites/create/12345.json or http://twitter.com/favorites/create/45567.xml
			--Returns: status element
		deferred
		end

	destroy_favorite (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_STATUS
			--Favorites the status specified in the ID parameter as the authenticating user.  Returns the favorite status when successful.
			--URL: http://twitter.com/favorites/destroy/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID of the status to favorite.
			--		Ex: http://twitter.com/favorites/destroy/12345.json or http://twitter.com/favorites/destroy/45567.xml
			--Returns: status element
		deferred
		end

feature -- Twitter: Notification Methods

	follow (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Enables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
			--URL:http://twitter.com/notifications/follow/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user to follow.
			--		Ex: http://twitter.com/notifications/follow/12345.xml or http://twitter.com/notifications/follow/bob.json
			--Returns: basic user information element
		deferred
		end

	leave (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Disables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
			--URL: http://twitter.com/notifications/leave/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen name of the user to leave.
			--		Ex:  http://twitter.com/notifications/leave/12345.xml or http://twitter.com/notifications/leave/bob.json
			--Returns: basic user information element	
		deferred
		end

feature -- Twitter: Block Methods

	create_block (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Blocks the user specified in the ID parameter as the authenticating user.  Returns the blocked user in the requested format when successful.  You can find out more about blocking in the Twitter Support Knowledge Base.
			--URL: http://twitter.com/blocks/create/id.format
			--Formats: xml, json
			--Method(s): POST
			--Parameters:
			--    * id.  Required.  The ID or screen_name of the user to block.  Ex: http://twitter.com/blocks/create/12345.json or http://twitter.com/blocks/create/bob.xml
			--Returns: basic user information element
		deferred
		end

	destroy_block (a_id: INTEGER; a_screen_name: detachable STRING): detachable TWITTER_USER
			--Un-blocks the user specified in the ID parameter as the authenticating user.  Returns the un-blocked user in the requested format when successful.
			--URL: http://twitter.com/blocks/destroy/id.format
			--Formats: xml, json
			--Method(s): POST, DELETE
			--Parameters:
			--    * id.  Required.  The ID or screen_name of the user to un-block.  Ex: http://twitter.com/blocks/destroy/12345.json or http://twitter.com/blocks/destroy/bob.xml
			--Returns: basic user information element
		deferred
		end

feature -- Twitter: Help Methods

	test: detachable STRING
			--Returns the string "ok" in the requested format with a 200 OK HTTP status code.			
			-- URL: http://twitter.com/help/test.format
			--Formats: xml, json
			--Method(s): GET			
		deferred
		end


note
	copyright: "Copyright (c) 2003-2009, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
