class DeviceTypes extends require( "./_rest_tunnel" )

	urlbase: "/devicetypes"

	ERRORS: =>
		@extend super, 
			"ENOTFOUND": [ 404, "Device not found." ]

module.exports = new DeviceTypes()