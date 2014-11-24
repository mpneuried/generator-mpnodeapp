# # Passwordless
# ### extends [Redisconnector](redisconnector.coffee.html)
#
# ### Exports: *Instance*
# 
# This module handles the token get and check for passwordless login.
# The token create will be done by the MilonST Data-API and called directly from [RestUsers.passwordless()`](../modules/rest/users.coffee.html)

# **internal modules**
# The [User Model](../model/users.coffee.html)
userM = require( "../model/users" )

class Passwordless extends require( "./redisconnector" )
	
	# ## defaults
	defaults: =>
		return @extend super, 
			# **tokenLen** *Number* Length of generated token
			tokenLen: 128
			# **redisPrefix** *String* token Keys will be prefixed with this string
			redisPrefix: "milon:pwls:"

	###	
	## constructor 
	###
	constructor: ->
		super
		@getToken = @_waitUntil( @_getToken, "connected" )
		# init redis connection
		@connect()
		return

	###
	## checkToken
	
	`passwordless.checkToken( token, cb )`
	
	check if a token from passwordless exists and if it matches the user data
	
	@param { String } token The passwordless token 
	@param { Function } cb Callback function 
	
	@api public
	###
	checkToken: ( token, cb )=>
		# check the token length
		if not token? or token.length isnt @config.tokenLen
			@_handleError( cb, "EINVALIDTOKEN" )
			return

		@debug "checkToken", token, @connected
		@getToken token, ( err, data )=>
			if err
				cb( err )
				return

			# `getToken` should return a valid `user_id`
			@debug "checkToken data", data
			if not data.user_id? or data.user_id.length isnt 5
				@_handleError( cb, "ENOUSERID", { uid: data.user_id } )
				return

			# read the user data
			userM.get data.user_id, { fields: [ "id","role","email","lang" ] }, ( err, userData )=>
				if err
					cb( err )
					return

				# check if the user's mail and the mail saved with the token a equal. This could fail if the user has changed his mail since generating the token.
				@debug "checkToken userData", userData
				if not data.email? or userData.email isnt userData.email
					@_handleError( cb, "EWRONGEMAIL", token: data.email, db: userData.email )
					return

				# return the user Data to generate the session
				cb( null, userData )	
				return
			return
		return

	###
	## _getToken
	
	`passwordless._getToken( token, cb )`
	
	Receive a token out of redis and try to delete it immediatelly
	
	@param { String } token The token taht will be used as part of the redis key  
	@param { Function } cb Callback function 
	
	@api private
	###
	_getToken: ( token, cb )=>
		# get and delete the token because if it's a valid token it should not be used any more.
		rM = []
		rM.push [ "GET", @config.redisPrefix + token ]
		rM.push [ "DEL", @config.redisPrefix + token ]

		@redis.multi( rM ).exec ( err, results )=>
			if err
				cb( err )
				return
			[ tokendata, deleted ] = results
			# a redis token has to be at least 9 cahrs long. 5 chars for the user_id and min 5 chars for email
			if not tokendata? or tokendata?.length <= 10
				@_handleError( cb, "EINVALIDTOKEN" )
				return
			@debug "redis token result", tokendata, deleted
			data = 
				user_id: tokendata[0..4]
				email: tokendata[5..]
			cb( null, data )
			return
		return


	###
	## ERRORS
	
	`passwordless.ERRORS()`
	
	Error detail mappings
	
	@return { Object } Return A Object of error details. Format: `"ERRORCODE":[ ststudCode, "Error detail" ]` 
	
	@api private
	###
	ERRORS: =>
		@extend super, 
			"EINVALIDTOKEN": [ 406, "This token is invalid." ]
			"ENOUSERID": [ 406, "User id (`<%= uid %>`) not found or invalid." ]
			"EWRONGEMAIL": [ 406, "The email do mot match each other. Token:`<%= token %>` DB:`<%= db %>`" ]

# create the instance and export it.
module.exports = new Passwordless()