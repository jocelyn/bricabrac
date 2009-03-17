note
	description: "Summary description for {TWITTER_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TWITTER_MESSAGE

feature -- Access

	id: detachable STRING
			-- a permanent unique id referencing an object, such as user or status
			-- Examples: 1145445329 (status)

	sender_id: detachable STRING
			-- unique id of the user that sent a direct message (see id)
			-- Example: 6633812

	text: detachable STRING
			-- escaped and HTML encoded status body
			-- Examples: I am eating oatmeal, The first tag is always <html>	

	recipient_id: detachable STRING
			-- unique id of the user that received a direct message (see id)
			-- Example: 1401881

	created_at: detachable STRING
			-- Description: timestamp of element creation, either status or user
			-- Example: Sat Jan 24 22:14:29 +0000 2009

	sender_screen_name: detachable STRING
			-- display name of the user that sent a direct message (see screen_name)
			-- Examples: tweetybird, johnd

	recipient_screen_name: detachable STRING
			-- display name of the user that sent a direct message (see screen_name)
			-- Examples: tweetybird, johnd	

	sender: detachable TWITTER_USER
--	    id
--	    name
--	    screen_name
--	    location
--	    description
--	    profile_image_url
--	    url
--	    protected
--	    followers_count

	recipient: detachable TWITTER_USER
--	    id
--	    name
--	    screen_name
--	    location
--	    description
--	    profile_image_url
--	    url
--	    protected
--	    followers_count

end
