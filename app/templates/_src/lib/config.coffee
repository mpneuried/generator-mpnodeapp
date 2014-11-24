# # Config
#
# ### Exports: *Instance*
#
# This module encapsulates the whole configuration to be able to require it everywhere

# **npm modules**
extend = require( "extend" )
_ = require( "lodash" )

# load the Package json
PackageJSON = require( "../package.json" )

# ## Config Defaults
DEFAULT = 
	version: PackageJSON.version
	server: 
		# **server.port** *Number* Server port
		port: 3008
		# **server.host** *String* Server host. Currently just for info
		host: "localhost"
		# **server.listenHost** *String* Express listen host.
		listenHost: null
		# **server.basepath** *String* Express base path. Every route will be prefixed with this path.
		basepath: "/"
		# **server.title** *String* Service title.
		title: PackageJSON.name
		# **server.appname** *String* App name used by redis-sessions as namespace.
		appname: "milon-mymilon"

	# **selfLink** *String* The link to the running server. E.g. used to generate the passwordless token-link.
	selfLink: "http://localhost:3008/"

	express:
		# **express.logger** *String* logger configuration
		logger: "dev"
		# **express.staticCacheTime** *Number* Caching time of static content in `ms`
		staticCacheTime: 1000 * 60 * 60 * 24 * 31
	
	restTunnel:
		# **restTunnel.dataBasePath** *String* Path to the milon-st data api
		dataBasePath: "http://localhost:3002"

	redis:
		# **redis.host** *String* Redis host name
		host: "localhost"
		# **redis.port** *Number* Redis port
		port: 6379
		# **redis.options** *Object* Redis options
		options: {}
		# **redis.client** *RedisClient* Exsiting redis client instance
		client: null
	

# load the local config if the file exists
try
	_localconf = require( "../config.json" )
catch _err
	if _err?.code is "MODULE_NOT_FOUND"
		_localconf = {}
	else
		throw _err


class Config

	###	
	## constructor 
	###
	constructor: ( @severity = "info" )->
		return

	###
	## init
	
	`config.init( input )`
	
	Init the configuration based on the `config.json` and the defaults.
	
	@param { Object } input A optional input to overwrite the existing configs
	
	@api public
	###
	init: ( input )=>
		# if config exists it has been inited before, so don't use the defaults and `config.json` for reinit
		if @config?
			@config = extend( true, @config, input, { version: PackageJSON.version } )
		else
			@config = extend( true, {}, DEFAULT, _localconf, input, { version: PackageJSON.version } )
		@_inited = true
		return

	###
	## all
	
	`config.all( logging )`
	
	Get all configurations.
	
	@param { Boolean } logging Add the default logging config to each key
	@param { Function }  Callback function 
	
	@return { Object } Return Complete configuration 
	
	@api public
	###
	all: ( logging = false )=>
		if not @_inited
			@init( {} )

		_all = for _k, _v of @config when _.isObject( _v )
			@get( _k, logging )
		return _all

	###
	## get
	
	`config.get( name, logging )`
	
	Get a single config key
	
	@param { String } name The config key 
	@param { Boolean } logging Add the default logging config 
	
	@return { String } Return The configuration of this key 
	
	@api public
	###
	get: ( name, logging = false )=>
		if not @_inited
			@init( {} )

		_cnf = @config?[ name ] or null
		if logging

			logging = 
				logging:
					severity: process.env[ "severity_#{name}"] or @severity
					severitys: "fatal,error,warning,info,debug".split( "," )
			return extend( true, {}, logging, _cnf )
		else
			return _cnf

# create the instance and export it.
module.exports = new Config( process.env.severity )