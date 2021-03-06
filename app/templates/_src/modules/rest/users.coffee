class RestUsers extends require( "./restbase" )

	model: require( "../../model/users" )

	createRoutes: ( basepath, router )=>
		
		router.get "#{basepath}/:id"<% if( usesessions ){ %>, @_checkAuth<% } %>, @get
		super
		return
		
	get: ( req, res )=>
		_id = req.params.id

		<% if( usesessions ){ %>
		if req.session.userid isnt _id
			@_handleError( res, "EFORBIDDEN" )
			return
		<% } %>

		@model.get( _id, @_return( res ) )
		return

module.exports = new RestUsers()