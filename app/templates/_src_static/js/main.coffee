window.jQuery = jQuery = require( "jquery" )
Bootstrap = require( "bootstrap" )

modules = []
modules.push require( "./modules/info" )

( ( $ )->
	$ ->
		for module in modules
			module.init()		
	return
)( jQuery )