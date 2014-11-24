window.jQuery = jQuery = require( "jquery" )
Bootstrap = require( "bootstrap" )

( ( $ )->
	$ ->
		<% if( addpassworlesslogin ){ %>
		$Classic = $( "#login_classic" )
		$Pwless = $( "#login_passwordless" )
		$( "#logintypes .chngtype" ).on "click", ( evnt )->
			isClassic = evnt.target.id is "changeto_classic"
			if isClassic
				$Pwless.hide()
				$Classic.show()
			else
				$Classic.hide()
				$Pwless.show()
			return
		<% } %> 
		$( "#keeplogin" ).tooltip()
		return
	return
)( jQuery )