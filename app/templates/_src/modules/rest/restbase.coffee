# # RestBase
# ### extends [Redisconnector](../../lib/apibase.coffee.html)
#
# ### Exports: *Class*
# 
# Basic Rest interface to be extended by other the rest endpoints
 
# **npm modules**
extend = require( "extend" )

# **internal modules**
# The [User Model](../../lib/config.coffee.html)
Config = require( "../../lib/config" )

class RestBase extends require( "../../lib/apibase" )

	# **model** *Model* The used main model out of "../models"
	model: null

	###
	## createRoutes
	
	`restbase.createRoutes( basepath, router )`
	
	required method to add the routes for this section to express
	
	@param { String } basepath Path prefix 
	@param { Express } router The express instance 
	
	@api private
	###
	createRoutes: ( basepath, router )=>
		super
		return

	###
	## get
	
	`restbase.get( req, res )`
	
	Standard get a element by key.
	
	@param { Request } req Express Request 
	@param { String } req.params.id Url param with ID 
	@param { Response } res Express Response 
	
	@api public
	###
	get: ( req, res )=>
		_id = req.params.id
		@model.get( _id, @_return( res ) )
		return

	###
	## update
	
	`restbase.update( req, res )`
	
	Update a element by key
	
	@param { Request } req Express Request 
	@param { String } req.params.id Url param with ID 
	@param { Object } req.body The Request body has to contain a JSON
	@param { Response } res Express Response 
	
	@api public
	###
	update: ( req, res )=>
		_id = req.params.id
		_body = req.body
		@model.update( _id, _body, @_return( res ) )
		return

	###
	## delete
	
	`restbase.delete( req, res )`
	
	Delete a element by key
	
	@param { Request } req Express Request 
	@param { String } req.params.id Url param with ID 
	@param { Response } res Express Response 
	
	@api public
	###
	delete: ( req, res )=>
		_id = req.params.id
		@model.delete( _id, @_return( res ) )
		return

	###
	## create
	
	`restbase.create( req, res )`
	
	Cretae a new element
	
	@param { Request } req Express Request 
	@param { Object } req.body The Request body has to contain a JSON
	@param { Response } res Express Response 
	
	@api public
	###
	create: ( req, res )=>
		_body = req.body
		@debug "create", _body, req.headers
		@model.create( _body, @_return( res ) )
		return

	###
	## find
	
	`restbase.find( req, res )`
	
	Query the collection.
	
	@param { Request } req Express Request 
	@param { Object } req.query Object of URL query params
	@param { Response } res Express Response 
	
	@api public
	###
	find: ( req, res )=>
		_query = req.query
		@model.find( _query, @_return( res ) )
		return

	###
	## _return
	
	`restbase._return( res, cb )`
	
	Generic return function to translate a callback return to a express http answer.
	This method retuns a function to use as callback handler.
	
	@param { Response } res Express response object 
	
	@return { Function } The callback handler
	
	@api private
	###
	_return: ( res )=>
		return ( err, result )=>
			if err
				@_error( res, err )
				return
			@_send( res, result )
			return

	###
	## _checkModel
	
	`restbase._checkModel( req, res, next )`
	
	Helper middleware to check for a defined and valid model
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	@param { Function } next Middleware success function
	
	@api private
	###
	_checkModel: ( req, res, next )=>
		if not @model?
			@_handleError( res, "ENOMODEL" )
			return
		next()
		return

	###
	## ERRORS
	
	`passwordless.ERRORS()`
	
	Error detail mappings
	
	@return { Object } Return A Object of error details. Format: `"ERRORCODE":[ ststudCode, "Error detail" ]` 
	
	@api private
	###
	ERRORS: =>
		return extend {}, super, 
			"ENOMODEL": [ 500, "No model defined" ]
			"EFORBIDDEN": [ 403, "You are not allowed!" ]

#export this class
module.exports = RestBase