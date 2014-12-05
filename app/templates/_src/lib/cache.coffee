# # Cache
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Instance*
# 
# Cache Interface

# **npm modules**
_ = require( "lodash" )
Memcached = require( "memcached" )

# **internal modules**
# [Config](./config.coffee.html)
config = require( "./config" )

class Cache extends require( "mpbasic" )( config )

	# ## defaults
	defaults: =>
		return @extend super, 
			# **type** *String* The cachetype. Currently only memcached is supported
			type: "memcached"
			# **host** *String|String[]* Cache server host
			host: "127.0.0.1"
			# **port** *Number* Cache server port
			port: 11211
			# **options** *Object* Cache client options
			options: 
				# **options.timeout** *Number* Default cache request timeout
				timeout: 1000

	###	
	## constructor 
	###
	constructor: ->
		super

		if @config.type is "memcached"
			_locations = []
			if _.isArray( @config.host )
				for _h in @config.host
					_locations.push @_getLocation( _h )
			else
				_locations.push @_getLocation( @config.host )

			@client = new Memcached( _locations, @config.options)

		else
			@_handleError( false, "EINVALIDCACHETYPE", type: @config.type )
		return

	###
	## get
	
	`cache.get( key, cb )`
	
	Get a cache object
	
	@param { String } key Key to get 
	@param { Function } cb Callback
	
	@api public
	###
	get: =>
		@debug "get", arguments
		@client.get.apply( @client, arguments )

	###
	## set
	
	`cache.set( key, value, ttl, cb )`
	
	Save data to the cache
	
	@param { String } key The key to save the value 
	@param { Buffer|JSON|String|Number } value The key to save the value 
	@param { Number } ttl how long the data needs to be stored measured in `seconds`
	@param { Function } cb Callback
	
	@return { String } desc 
	
	@api private
	###
	set: =>
		@debug "set", arguments
		@client.set.apply( @client, arguments )

	###
	## del
	
	`cache.del( key, cb )`
	
	Delete a cache object
	
	@param { String } key Key to del 
	@param { Function } cb Callback
	
	@api public
	###
	del: =>
		@debug "del", arguments
		@client.del.apply( @client, arguments )

	###
	## _getLocation
	
	`cache._getLocation( host )`
	
	generate a valid memcache host string
	
	@param { String } host Host string 
	
	@return { String } Valif host port combination 
	
	@api private
	###
	_getLocation: ( host )=>
		if host.indexOf( ":" ) >= 0
			return host
		else
			return host + ":" + @config.port


	###
	## ERRORS
	
	`passwordless.ERRORS()`
	
	Error detail mappings
	
	@return { Object } Return A Object of error details. Format: `"ERRORCODE":[ ststudCode, "Error detail" ]` 
	
	@api private
	###
	ERRORS: =>
		@extend super, 
			"EINVALIDCACHETYPE": [ 500, "The cache type `<<% print("%") %>= type <% print("%") %>>` is not supported" ]


# create the instance and export it.
module.exports = new Cache()