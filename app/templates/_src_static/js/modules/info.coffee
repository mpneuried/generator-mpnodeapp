$ = require( "jquery" )
tmpls = require( "../lib/tmpls" )

class ModuleInfo

	id: "#mym-info"
	
	init: =>
		@$el = $( @id )
		@addEvents()
		return

	addEvents: =>
		@$el.on "click", @_open
		@$el.on "click", ".close", @_close
		return

	_open: ( evnt )=>
		evnt.preventDefault()
		evnt.stopPropagation()
		if not @$el.hasClass( "open" )
			@preRender @open
		return

	_close: ( evnt )=>
		evnt.preventDefault()
		evnt.stopPropagation()
		if @$el.hasClass( "open" )
			@close()
		return

	preRender: ( cb )=>
		$.ajax 
			url: "/api/users/#{window._init.user.id}"
			success: ( @data )=>
				console.log @data
				cb()
				return
			error: @_onError()
		
	open: =>
		@$el.html( tmpls( "modules/info.html", @data ) )
		@$el.addClass( "open" )
		return

	close: =>
		@$el.removeClass( "open" )
		@$el.html( tmpls( "components/info_content.html" ) )
		return

	_onError: =>
		# TODO better error handling
		console.log "ERROR", arguments
		return


module.exports = new ModuleInfo()