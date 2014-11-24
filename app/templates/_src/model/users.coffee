<% if( usesessions ){ %>
bcrypt = require( "bcrypt" )
<% } %>
_ = require( "lodash" )

config = require( "../lib/config" )
utils = require( "../lib/utils" )


class ModelUser extends require( "./_rest_tunnel" )

	urlbase: "/users"
<% if( usesessions ){ %>
	login: ( email, password, cb )=>

		if not email?.length or not password?.length
			@_delayError( cb, "ELOGINFAILED" )
			return
			
		_handle = ( err, data )=>
			if err
				cb( err )
				return

			user = data?[ 0 ]
			if not user?
				@_delayError( cb, "ELOGINFAILED" )
				return

			if not password?
				@_delayError( cb, "ELOGINFAILED" )
				return

			bcrypt.compare password, user.password, ( err, same )=>
				if err or not same
					@_delayError( cb, "ELOGINFAILED" )
					return
				cb( null, user )
				return
			return

		@request.get( @urlRoot + "login", email: email , @_return( "login", _handle ) )
		return

	_delayError: ( cb, err, data, errExnd )=>
		_delay = utils.randRange( 10, 200 )
		_.delay( @_handleError, _delay, cb, err, data, errExnd )
		return
<% if( addpassworlesslogin ){ %>
	loginPasswordless: ( email, cb )=>
		if not email?.length
			@_delayError( cb, "ELOGINFAILED" )
			return
			
		_handle = ( err, data )=>
			if err
				cb( err )
				return

			user = data?[ 0 ]
			if not user?
				@_delayError( cb, "ELOGINFAILED" )
				return
				
			cb( null, user )
			return

		_linkprefix = config.get( "selfLink" ) + "login/passwordless/"

		@request.get( @urlRoot + "login/passwordless", { email: email, linkprefix: _linkprefix } , @_return( "login", _handle ) )
		return
<% } %>
<% } %>
	ERRORS: =>
		@extend super, 
			"ENOTFOUND": [ 404, "User not found." ]<% if( usesessions ){ %>
			"ELOGINFAILED": [ 401, "Login faild. Please check your e-mail and password" ]<% } %>

module.exports = new ModelUser()