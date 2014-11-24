$ = require( "jquery" )
require( "jst" )
nunjucks = require( "nunjucks" )
_lang = null

fnRender = ( name, data={} )=>
	<% if( usei18n ){ %>
	_lang = $( "html" ).attr( "lang" ) 
	data.gettext = ( key )->
		console.log( "TODO Load i18n texts" )
		return key
	<% } %>
	return nunjucks.render( name, data )

module.exports = fnRender