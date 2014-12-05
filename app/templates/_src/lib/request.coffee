# # HRequest
# ### extends [NPM:MPBasic](https://github.com/mpneuried/mpbaisc)
#
# ### Exports: *Class*
# 
# Request module based on hyperquest.
# It provides a reduced api of the popular request module on top of hyperquest.
# So it does the magic of handing the data to send, json converting and network chunks handling.
#
# ## TODOS
# * optimize this module to return a promise interface
# * fix the post shortcut to be able to pass in the payload data

# **node modules**
StringDecoder = require('string_decoder').StringDecoder
querystring = require( "querystring" )
http = require( "http" )
# additional upgrade the max sockets. 
http.globalAgent.maxSockets = 30

# **npm modules**
hyperquest = require( "hyperquest" )
_ = require('lodash')

# **internal modules**
# [Config](./config.coffee.html)
Config = require( "../lib/config" )

class HRequest extends require( "mpbasic" )( Config )

	# ## defaults
	defaults: =>
		return @extend true, super,
			# **method** *String* Default HTTP Method if pure `request` is used.
			method: "GET"
			# **payloadMethods** *String[]* An array of http methods that supports a payload.
			payloadMethods: [ "POST", "PUT", "PATCH" ]

	###
	## get
	
	`request.get( url [, data ][, headers], cb )`
	
	Start a http get call
	
	@param { String } url the url to call 
	@param { Object } [data] the query params as object
	@param { Object } [headers] Object of header keys 
	@param { Function } cb Callback function 
	
	@api public
	###
	get: ( args..., cb )=>
		[ url, data, headers ] = args

		_opts = 
			method: "GET"
			path: url
			headers: headers

		_opts.headers = {} if not _opts.headers?

		# set the general headers
		_opts.headers[ 'content-length' ] = 0 if not _opts?.headers?[ 'content-length' ]?
		_opts.headers[ 'content-type' ] = "application/json" if not _opts?.headers?[ 'content-type' ]?
		_opts.path += if _opts.path.indexOf( "?" ) >= 0 then "&" else "?" + querystring.stringify( data )
		@request( _opts, cb )
		return

	###
	## post
	
	`request.post( url [, data ][, headers], cb )`
	
	Start a http post call
	TODO fix handling of post payload
	
	@param { String } url the url to call 
	@param { Object } [data] the query params as object
	@param { Object } [headers] Object of header keys 
	@param { Function } cb Callback function 
	
	@api public
	###
	post: ( args..., cb )=>
		[ url, data, headers ] = args

		_opts = 
			method: "POST"
			path: url
			headers: headers
			json: data

		_opts.headers = {} if not _opts.headers?
		_opts.headers[ 'content-type' ] = "application/json" if not _opts?.headers?[ 'content-type' ]?

		@request( _opts, cb )
		return

	###
	## get
	
	`request.get( url [, data ][, headers], cb )`
	
	Shortcut to get json data
	
	@param { String } url the url to call 
	@param { Object } [data] the query params as object
	@param { Object } [headers] Object of header keys 
	@param { Function } cb Callback function 
	
	@api public
	###
	getJSON: ( args..., cb )=>
		[ url, data, headers ] = args
		@get url, data, headers, @_responseDataHandler( cb )
		return


	###
	## request
	
	`request.request( opt, cb )`
	
	General request method to request data via http
	
	@param { Object } opt Request options 
	@param { Function } cb Callback function 
	
	@api public
	###
	request: ( opt, cb )=>
		
		@prepareBody opt, ( err, _body, _forcedHeaders )=>
			if err
				cb( err )
				return
			try
				_path = @preparePath( opt )
				_opts = @prepareOpts( opt, _body, _forcedHeaders )
			catch _err
				cb( _err )
				return

			@log "debug", "run request", [_path, _opts, _body, _body?.toString() ]
			request = hyperquest( _path, _opts )

			@_responseHandler( cb, request, _path, _opts )

			if _body?
				request.write( _body )
			
			if _opts.method in @config.payloadMethods
				request.end()

			return
		return 

	###
	## prepareBody
	
	`request.prepareBody( id, cb )`
	
	prepare the body data and do a json stringify, buffer handling, ...
	
	@param { Object } opt Request options 
	@param { Function } cb Callback function 
	
	@api private
	###
	prepareBody: ( opt, cb )=>
		_body = null
		_fHeaders = {}

		if opt.json?
		# prepare raw body
			if _.isString( opt.json )
				_body = new Buffer( opt.json )
			else

				try
					_sjson = JSON.stringify( opt.json )
				catch _e
					@_handleError( cb, "EJSONSTRINGIFY" )
					return

				_body = new Buffer( _sjson )

			_fHeaders[ "Content-type" ] = "application/json"

		else if opt.body?
		# prepare raw body
			if Buffer.isBuffer( opt.body )
				_body = opt.body
			else if _.isString( opt.body )
				_body = new Buffer( opt.body )
			else 
				@log "warning", "used body unlike Buffer or String!", opt.body
				_body = opt.body

		if _body?.length
			_fHeaders[ "Content-length" ] = _body.length

		cb( null, _body, _fHeaders )
		return

	###
	## preparePath
	
	`request.preparePath( opt )`
	
	prepare the path to use
	
	@param { Object } opt Request options 
	
	@return { String } the resulting path 
	
	@api private
	###
	preparePath: ( opt )=>
		_url = opt.url or opt.uri or opt.path
		_qs = ""
		if opt.qs?
			if _.isString( opt.qs )
				_qs = opt.qs
			else
				_qs = querystring.stringify( opt.qs )

		if _qs?.length
			if _url.indexOf( "?" ) < 0
				return _url + "?" + _qs
			else
				return _url + "&" + _qs
		else
			return _url

	###
	## prepareOpts
	
	`request.prepareOpts( opt, _body, _forcedHeaders )`
	
	prepare and check the options 
	
	@param { Object } opt Request options 
	@param { Object|String|Buffer } _body Request body data 
	@param { Object } [_forcedHeaders] A object of prio 1 headers that wil loverwrite all existing keys
	
	@return { Object } final request options
	
	@api private
	###
	prepareOpts: ( opt, _body, _forcedHeaders )=>
		_method = opt.method or @config.method
		if _body? and _method not in @config.payloadMethods
			@_handleError( null, "EINVALIDMETHOD" )
			return

		method: _method
		headers: @extend( {}, opt.headers or {}, _forcedHeaders )

	###
	## _responseHandler
	
	`request._responseHandler( cb, request, _path, _opts )`
	
	Request halder to collect the network chunks emitted by hyperquest
	
	@param { Function } cb Callback function 
	@param { Request } request The request object generated by hyperquest 
	@param { String } _path the called path
	@param { Object } _opts The used request options
	
	@api private
	###
	_responseHandler: ( cb, request, _path, _opts )=>
		_err = ""
		_body = ""
		res = null
		decoder = new StringDecoder( "utf8" )

		request.on "response", ( response )=>
			res = response
			@log "debug", "request response", [_path, _opts, _body, _body?.toString() ]
			return

		request.on "data", ( chunk )=>
			_body += decoder.write( chunk ) 
			return

		request.on "error", ( chunk )=>
			@log "debug", "request error", [chunk.toString()]
			_err += chunk
			cb( _err, res )
			cb = null
			return

		request.on "end", =>
			if _err
				@log "debug", "end error", _err
				cb( _err, res ) if cb?
				return

			@log "debug", "request result", _body, res?.headers
			#console.log _body
			if res?.headers?[ "content-type" ]?.toLowerCase().indexOf( "application/json" ) >= 0
				try
					res.body = JSON.parse( _body )
			else if _body?.length 
				res.body = _body
			
			if res.statusCode > 300 and res.statusCode <= 400
				_err = new Error()
				_err.name = "redirect"
				_err.message = "TODO: follow redirects in `request` module."
				_err.statusCode = res.statusCode
				cb( _err )
				return

			# handle error if code isnt 200
			if res.statusCode > 200 and res.statusCode <= 400
				_err = new Error()
				_err.name = res.body?.errorcode or "unkonwn"
				_err.message = res.body?.message or ""
				_err.statusCode = res.statusCode
				cb( _err )
				return
			cb( null, res ) if cb?
			return

		
		return

	###
	## _responseDataHandler
	
	`request._responseDataHandler( id )`
	
	Handle JSON data after the general `_responseHandler`
	
	@param { Function } id The callback function 
	
	@return { Function } a function to handle the json resopnse 
	
	@api private
	###
	_responseDataHandler: ( cb )=>
		return ( err, res )=>

			
			# try to convert data to JSON
			try data = JSON.parse( res.body or "" )

			# check status code and content-type
			if res.statusCode is 200 and res.headers[ "content-type" ].indexOf( "application/json" ) >= 0

				if ( _.isArray( data ) and data.length is 0 ) or not data?
					# got an empty result
					@_handleError( cb, "notfound", data )
				else
					# return result
					if _.isFunction( cb )
						cb( null, data )

			else
				# on error
				try data = JSON.parse( res.body or "" )
				@_handleError( cb, data?.errorcode or data?.error?.errorcode or "EHTTPNOT200", body: res.body, statusCode: res.statusCode )
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
			"EJSONSTRINGIFY": [ 500, "Cannot stringify the given `json` data." ]
			"EHTTPNOT200": [ 500, "Cannot get the data" ]
			"EINVALIDMETHOD": [ 405, "If you pass body data via `body` or `json` you have to use a method of `POST, `PUT` or `PATCH"]

# expoert the class
module.exports = HRequest