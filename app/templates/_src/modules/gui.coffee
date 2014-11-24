# # GUI
# ### extends [Redisconnector](../lib/apibase.coffee.html)
#
# ### Exports: *Instance*
# 
# Module to handle the frontend rendering

# **node modules**
querystring = require( "querystring" ) 

# **npm modules**
_ = require( "lodash" )

# **internal modules**
# [config](../lib/config.coffee.html)
config = require( "../lib/config" )
# [User Model](../model/users.coffee.html)
userM = require( "../model/users" )
# [Passwordless](../lib/passwordless.coffee.html)
passwordless = require( "../lib/passwordless" )

class GUI extends require( "../lib/apibase" )

	# ## defaults
	defaults: =>
		@extend super, 
			# **loginSuccessPath** *String* Redirect path if there is already a session
			loginSuccessPath: "/index.html"
			# **loginFailedPath** *String* Redirect path if there is already no session
			loginFailedPath: "/login.html"


	###
	## createRoutes
	
	`gui.createRoutes( basepath, router )`
	
	The basic method to add routes to express.
	
	@param { String } basepath Basic path prefix 
	@param { Express } router The express app instance 
	
	@api private
	###
	createRoutes: ( basepath, router )=>
		# main pages
		router.get "#{basepath}index.html", @_checkAuth, @index
		router.get "#{basepath}index", @_checkAuth, @index
		router.get "#{basepath}", @_checkAuth, @index

		# passwordless logins
		router.post "#{basepath}login/passwordless", @passwordless
		router.get "#{basepath}login/passwordless/:token", @checkToken

		# login and exit
		router.post "#{basepath}login", @login
		router.get "#{basepath}exit", @exit

		# login html
		router.get "#{basepath}login.html", @loginPage
		router.get "#{basepath}login", @loginPage
		super
		return

	###
	## loginPage
	
	`gui.loginPage( req, res )`
	
	Render the login page
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	loginPage: (req, res)=>
		# redirect to the users home page if he has a active session
		if req?.session?.userid and req?.session?.role
			res.redirect( @config.loginSuccessPath )
			return
		
		_query = _.pick( req.query, [ "msg", "mail", "type" ] )
		_query.title = config.get( "server" ).title

		res.render('login_email_pw', _query )
		return

	###
	## index
	
	`gui.index( req, res )`
	
	Render the index page
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	index: (req, res)=>
		# redirect to the login page if there is no active session
		if not req?.session?.userid or not req?.session?.role
			res.redirect( @config.loginFailedPath )
			return

		# get the user
		userM.get req.session.userid, ( err, userdata )=>
			if err
				@_error( res, err )
				return

			_tmpl = 
				title: config.get( "server" ).title
				user: userdata
				# stringify frontend init data to be able to parse it within the template
				init: JSON.stringify
					user: userdata

			res.render('index', _tmpl )
			return
		return

	###
	## login
	
	`gui.login( req, res )`
	
	Try to login a user with the classic login
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	login: ( req, res )=>
		_handler = ( err, data )=>
			if req.is('json')
				@_return( res )( err, data )
				return
			if err
				res.redirect( @config.loginFailedPath + "?type=classic&msg=" + err.name + ( if req.body?.email? then "&mail=" + req.body.email else "" ) )
				return
			
			res.redirect( @config.loginSuccessPath )
			return

		# extract the data for the classic login
		_mail = req.body.email
		_pw = req.body.password

		userM.login _mail, _pw, ( err, user )=>
			if err
				_handler( err )
				return
			@_createSession( req, user, _handler )
			return
		return

	###
	## exit
	
	`gui.exit( req, res )`
	
	destroy a user session
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	exit: ( req, res )=>
		# only destroy on a existing session
		if req?.session?.userid and req?.session?.role
			_uid = req?.session?.userid
			_email = req?.session?.email
			_lang = req?.session?.lang
			req.session.destroy ( err, done )=>
				if err
					@error "destroy session #{_uid}", err

				# generate a nice new login page
				_query = {}
				_query.mail = _email if _email?
				_query.lang = _lang if _lang?
				
				res.redirect( @config.loginFailedPath + "?#{ querystring.stringify( _query ) }")
				return 
			return

		# if no session exists just redirect to login
		res.redirect( @config.loginFailedPath + "" )
		return

	###
	## passwordless
	
	`gui.passwordless( req, res )`
	
	send the user a mail with a login token
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	passwordless: ( req, res )=>
		_mail = req.body.email

		userM.loginPasswordless _mail, ( err, result )=>
			if err
				@error "loginPasswordless", err
			else
				@debug "loginPasswordless", result
			res.redirect( @config.loginFailedPath + "?msg=MAILSEND&mail=#{_mail}" )
			return
		return

	###
	## checkToken
	
	`gui.checkToken( req, res )`
	
	If check the token form a email.
	Check for existance and if the email has not been changed
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	
	@api private
	###
	checkToken: ( req, res )=>
		_token = req.params.token
		passwordless.checkToken _token, ( err, user )=>
			@debug "checkToken user", err, user
			if err
				@error "checkToken", err
				res.redirect( @config.loginFailedPath + "?msg=TOKEININVALID" )
				return

			# if the token is valid create the session
			@_createSession req, user, ( err )=>
				if err
					res.redirect( @config.loginFailedPath + "?msg=" + err.name )
					return
				res.redirect( @config.loginSuccessPath )
				return
			return  
		return

	###
	## _createSession
	
	`gui._createSession( req, user, cb )`
	
	upgrade a user session
	
	@param { Request } req Express Request 
	@param { Object } user The user data
	
	@api private
	###
	_createSession: ( req, user, cb )=>
		req.session.upgrade user.id, ( err )=>
			if err
				cb( err )
				return

			req.session.userid = user.id
			req.session.lang = user.lang
			req.session.email = user.email
			req.session.role = user.role

			user.sessiontoken = req.sessionID

			cb( null, _.omit( user, [ "password", "isactive" ] ) )
			return
		return


# create the instance and export it.
module.exports = new GUI()