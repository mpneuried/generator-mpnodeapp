frisby = require('frisby')
extend = require( "extend" )

Config = require( "../lib/config" )

# load the local config if the file exists
try
	_cnf = require( "../config_test.json" )
catch _err
	if _err?.code is "MODULE_NOT_FOUND"
		_cnf = {}
	else
		throw _err

_cnfServer = Config.get( "server" )

_cnf = extend( true, {},
	baseurl: "http://#{_cnfServer.host}:#{_cnfServer.port}#{_cnfServer.basepath}"

	testuser:
		firstname: null
		lastname: null
	<% if( usesessions ){ %>
		email: "mytest.user@example.com"
		pw: "tester"
	<% }else{ %>
		id: "abcde"
	<% } %>
	, _cnf )

<% if( usesessions ){ %>
root.sessiontoken = null
root.userid = null
<% }else{ %>
root.userid = _cnf.testuser.id
<% } %>

<% if( usesessions ){ %>
frisby
	.create( "Login" )
	.post( _cnf.baseurl + "api/users/login", email: _cnf.testuser.email, password: _cnf.testuser.pw )
	#.inspectBody()
	.expectStatus( 200 )
	.expectHeaderContains( "content-type", "application/json" )
	.expectJSON
		email: _cnf.testuser.email
	.after (err, res, body)->
		return if err

		data = JSON.parse( body )
		root.sessiontoken = data.sessiontoken
		root.userid = data.id

		frisby.globalSetup
			request:
				headers: { "Cookie": "#{_cnfServer.appname}=#{root.sessiontoken}" }

		_startTest()
		return
	.toss()
<% } %>

_startTest = ->
	frisby
		.create( "GET User" )
		.get( _cnf.baseurl + "api/users/#{root.userid}")
		#.inspectBody()
		.expectStatus( 200 )
		.expectHeaderContains( "content-type", "application/json" )
		.expectJSON(
			id: userid
			email: _cnf.testuser.email
		)
		.toss()
	return
	
<% if( !usesessions ){ %>
_startTest()
<% } %>