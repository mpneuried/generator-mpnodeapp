_ = require( "lodash" )

class RestDevicetypes extends require( "./restbase" )

	model: require( "../../model/devicetypes" )

	createRoutes: ( basepath, router )=>

		router.get "#{basepath}/:id", @_checkAuth, @get
		router.get "#{basepath}", @_checkAuth, @find

		super
		return


module.exports = new RestDevicetypes()