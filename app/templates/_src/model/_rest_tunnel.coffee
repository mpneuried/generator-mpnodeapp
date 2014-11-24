# # RestTunnel
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
# 
# Generic class the handle the standard cases to talk with the milon-st data-api

# **npm modules**
_ = require( "lodash" )

# **internal modules**
# The [Config](../lib/config.coffee.html)
Config = require( "../lib/config" )

# The [Request Helper](../lib/request.coffee.html)
request = new ( require( "../lib/request" ) )()

class RestTunnel extends require( "mpbasic" )( Config )
	
	# **request** *Request-Instance* Module to make http calls
	request: request

	###	
	## constructor 
	###
	constructor:->
		# getter to read the name of this module
		@getter "name", @_getName
		# getter to read the base url
		@getter "urlRoot", @_getUrlRoot
		super

		@configTunnel = Config.get( "restTunnel" )
		return

	###
	## _getName
	
	`_rest_tunnel._getName()`
	
	Getter Method to read the module name. This method exists to be overwritten
	
	@return { String } Module name 
	
	@api private
	###
	_getName: =>
		return @constructor.name

	###
	## _getUrlRoot
	
	`_rest_tunnel._getUrlRoot()`
	
	GEtter Method to read the url root. This method exists to be overwritten
	
	@return { String } Url roote
	
	@api private
	###
	_getUrlRoot: =>
		return @configTunnel.dataBasePath + @urlbase + "/"

	###
	## get
	
	`_rest_tunnel.get( _id [, options ], cb )`
	
	Get a element from the data-api
	
	@param { String } _id key to get
	@param { Object } [options] options
	@param { Boolean } [options.errorOnEmpty=true] return an error if the result is empty. Used for get methods
	@param { Function } cb Callback function
	
	@api public
	###
	get: ( args..., cb )=>
		[ _id, options ] = args
		if not options?
			options = {}
		
		options.errorOnEmpty = true

		@request.get( @urlRoot + _id, @_return( "get", cb, options ) )
		return

	###
	## find
	
	`_rest_tunnel.find( query [, options ], cb )`
	
	query the data-api
	
	@param { Object } query Query object to filter the data 
	@param { Object } [options] options
	@param { Function } cb Callback function 
	
	@api public
	###
	find: ( args..., cb )=>
		[ query, options ] = args
		if not options?
			options = {}
		
		@request.get( @urlRoot, query, @_return( "find", cb, options ) )
		return

	###
	## create
	
	`_rest_tunnel.create( body [, options ], cb )`
	
	Create a new element within the data-api
	
	@param { Object } body Data to create a element
	@param { Object } [options] options
	@param { Function } cb Callback function 
	
	@api public
	###
	create: ( args..., cb )=>
		[ body, options ] = args
		if not options?
			options = {}
		
		_rOpt = 
			path: @urlRoot
			json: body
			method: "POST"

		@request.request( _rOpt, @_return( "create", cb, options ) )
		return

	###
	## update
	
	`_rest_tunnel.update( _id, body [, options ], cb )`
	
	Create a new element within the data-api
	
	@param { String } _id Key to update
	@param { Object } body Data to update the element
	@param { Object } [options] options
	@param { Function } cb Callback function 
	
	@api public
	###
	update: ( args..., cb )=>
		[ _id, body, options ] = args
		if not options?
			options = {}

		_rOpt = 
			path: @urlRoot + _id
			json: body
			method: "PUT"

		@request.request( _rOpt, @_return( "update", cb, options ) )
		return

	###
	## delete
	
	`_rest_tunnel.delete( _id [, options ], cb )`
	
	Delete a element by key
	
	@param { String } _id key to delete 
	@param { Object } [options] options
	@param { Function } cb Callback function 
	
	@api public
	###
	delete: ( args..., cb )=>
		[ _id, options ] = args
		if not options?
			options = {}

		_rOpt = 
			path: @urlRoot + _id
			method: "DELETE"

		@request.request( _rOpt, @_return( "update", cb, options ) )
		return

	###
	## _return
	
	`_rest_tunnel._return( type, cb [, options ] )`
	
	Helper method to create a REST return handler.
	This method retuns a function to use as callback handler.
	
	@param { String } type The request type. Usually one of: "get", "find", "create", "update", "delete".
	@param { Function } cb  Callback function 
	@param { Object } [options] options
	
	@return { Function } The callback handler 
	
	@api private
	###
	_return: ( type, cb, options={} )=>
		return ( err, response )=>
			if err
				cb( err )
				return

			@debug "tunnel return", err, response.statusCode, data
			if response.statusCode >= 400
				@_handleError( cb, data )
				return
				
			data = response.body

			if options.errorOnEmpty and ( _.isArray( data ) and not data.length ) or _.isEmpty( data )
				@_handleError( cb, "ENOTFOUND" )
				return
			else if not data?
				data = []
		
			cb( null, @_postProcess( data, options ) )
			return

	###
	## _postProcess
	
	`_rest_tunnel._postProcess( data, options )`
	
	Called on every return to be able to post process the data
	
	@param { Object|Array } data Raw data element or list from the data-api 
	@param { Object } options The used options 
	
	@return { Array|Object } The processed data or list
	
	@api private
	###
	_postProcess: ( data, options )=>
		@debug "_postProcess", data, options
		if _.isArray( data )
			_ret = []
			for el, idx in data
				_ret.push @_postProcess( el, options )
			return _ret

		return @_postProcessElement( data, options )

	###
	## _postProcessElement
	
	`_rest_tunnel._postProcessElement( data, options )`
	
	Postprocess a element. The method is intended to be overwritten
	
	@param { Object|String|Number } data Raw data element from the data-api.
	@param { Object } options The used options 
	
	@return { String } The processed data
	
	@api private
	###
	_postProcessElement: ( data, options )=>
		return data

	###
	## ERRORS
	
	`passwordless.ERRORS()`
	
	Error detail mappings
	
	@return { Object } Return A Object of error details. Format: `"ERRORCODE":[ ststudCode, "Error detail" ]` 
	
	@api private
	###
	ERRORS: =>
		return @extend {}, super, 
			"ENONAME": [ 500, "A `this.name` key as string is required" ]
			"ENOTFOUND": [ 404, "Element of `#{ @name }` not found" ]

#export this class
module.exports = RestTunnel
