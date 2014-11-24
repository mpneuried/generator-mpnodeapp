# # RedisConnector
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
#
# Basic module to handle a redis connection.
# Just call `@connect()` within the constructor to connect savely to redis
#
# ### Class-Vars
# 
# * **redis** *RedisClient* the generated redis client instance
# * **connected** *Boolean* Flag to mark if the module is currently connected to redis

# ### Events
# 
# * **connected**: emitted on redis connect.
# * **disconnect**: emitted on redis disconnect.
# * **redis:error**: emitted on redis error.
#   * **err** *Error* The passed error object

# **npm modules**
redis = require( "redis" )

# **internal modules**

# [Config](./config.coffee.html)
config = require( "../lib/config" )

# internal var to reuse only one redis client
globalclient = {}

class RedisConnector extends require( "mpbasic" )( config )

	# ## defaults
	defaults: =>
		return @extend super, 
			# **redisConfigKey** *String* The config key to load redis
			redisConfigKey: "redis"
			# **seperateClient** *Boolean* Force create of a new client and not use the global single client.
			seperateClient: false


	###	
	## constructor 
	###
	constructor: ->
		super
		# define the `connected` flag
		@connected = false
		return

	###
	## connect
	
	`redisconnector.connect()`
	
	Connect to redis and add the renerated client th `@redis`
	
	@return { RedisClient } Return The Redis Client. Eventually not conneted yet. 
	
	@api public
	###
	connect: =>
		# get the redis config
		@configRedis = config.get( @config.redisConfigKey )

		if @configRedis.client?.constructor?.name is "RedisClient"
			# try to use the passed client
			@redis = @configRedis.client
		else if not @configRedis.seperateClient and globalclient?[@config.redisConfigKey]?.constructor?.name is "RedisClient"
			# try to use the global client of this config key
			@redis = globalclient[@config.redisConfigKey]
		else
			# generate a new client
			try
				redis = require("redis")
			catch _err
				@error( "you have to load redis via `npm install redis hiredis`" )
				return
			@redis = redis.createClient( @configRedis.port or 6379, @configRedis.host or "127.0.0.1", @configRedis.options or {} )

			# save the new client to the global var
			if not @config.seperateClient
				globalclient[ @config.redisConfigKey ] = @redis

		# check if this redis instance is allready conencted
		@connected = @redis.connected or false

		# listen to the redis connect event and set the class vars
		@redis.on "connect", =>
			@connected = true
			@debug "connected"
			@emit( "connected" )
			return

		# listen to redis errors
		@redis.on "error", ( err )=>
			# if it's a connection error emit the disconnect
			if err.message.indexOf( "ECONNREFUSED" )
				@connected = false
				@emit( "disconnect" )
			else
				@error( "Redis ERROR", err )
				@emit( "redis:error", err )
			return

		return @client

	###
	## _getKey
	
	`redisconnector._getKey( id, name )`
	
	Samll helper to prefix and get a redis key. 
	
	@param { String } id The key 
	@param { String } name the class name
	
	@return { String } Return The generated key 
	
	@api public
	###
	_getKey: ( id, name = @name )=>
		_key = @configRedis.prefix or ""
		if name?
			_key += ":#{name}"
		if id?
			_key += ":#{id}"
		return _key

#export this class
module.exports = RedisConnector