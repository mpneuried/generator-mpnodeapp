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
		email: "mp+plantester@tcs.de"
		pw: "tester"
		token: "desfire-qaywsxedc4321"
	, _cnf )

root.sessiontoken = null
root.userid = null

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

		_fnAfterLogin()
		return
	.toss()

_fnAfterLogin = ->
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

		frisby
			.create( "GET Devicetype 1" )
			.get( _cnf.baseurl + "api/devicetypes/1")
			#.inspectBody()
			.expectStatus( 200 )
			.expectHeaderContains( "content-type", "application/json" )
			.expectJSON( id: 1 )
			.toss()

		frisby
			.create( "GET all Devicetypes" )
			.get( _cnf.baseurl + "api/devicetypes/")
			#.inspectBody()
			.expectStatus( 200 )
			.expectHeaderContains( "content-type", "application/json" )
			.expectJSONTypes( "*", { id: Number, device_id: String } )
			.toss()

		

	return
