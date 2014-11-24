'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');

var MpnodeappGenerator = yeoman.generators.Base.extend({
  initializing: function () {
    this.pkg = require('../package.json');
  },

  prompting: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay(
      'Welcome to the well-made Mpnodeapp generator!'
    ));

    var prompts = [{
      name: 'githubuser',
      message: 'The github username?',
      default: "username"
    },{
      name: 'appname',
      message: 'The name of this app?',
      default: "appname"
    },{
      name: 'appdesc',
      message: 'The description of this app?',
      default: "App description ..."
    },{
      name: 'appversion',
      message: 'The initial version of this app?',
      default: "0.0.1"
    },{
      name: 'minnodeversion',
      message: 'The minimal node version',
      default: "0.10.0"
    },{
      type: "confirm",
      name: 'isprivate',
      message: 'Is it a private project?',
      default: true
    },{
      name: 'expressport',
      message: 'Express port to listen?',
      default: "3000"
    },{
      name: 'externalapipath',
      message: 'Path to the external data api',
      default: "http://localhost:3002"
    },{
      type: "list",
      name: 'servertype',
      choices: [ "GUI", "only-REST" ],
      message: 'Server type?',
      default: "GUI"
    },{
      type: "confirm",
      name: 'useclientviews',
      message: 'Add client-side templateing?',
      when: function( curranswers ){ return curranswers[ "servertype" ] === "GUI" ? true : false },
      default: true
    },{
      type: "confirm",
      name: 'usei18n',
      message: 'Add i18n translations?',
      when: function( curranswers ){ return curranswers[ "servertype" ] === "GUI" ? true : false },
      default: true
    },{
      type: "confirm",
      name: 'useredis',
      message: 'Add redis stubs?',
      default: true
    },{
      type: "confirm",
      name: 'usesessions',
      message: 'Add session handling and loginpage?',
      when: function( curranswers ){ return curranswers[ "useredis" ] ? true : false },
      default: true
    },{
      type: "confirm",
      name: 'addpassworlesslogin',
      message: 'Add stubs for passwordless login?',
      when: function( curranswers ){ return curranswers[ "usesessions" ] ? true : false },
      default: true
    },{
      name: 'sessionappname',
      message: 'Session app name?',
      when: function( curranswers ){ return curranswers[ "usesessions" ] ? true : false },
      default: function( curranswers ){ return curranswers[ "appname" ] },
    },{
      type: "confirm",
      name: 'usetests',
      message: 'Add REST tests by frisby?',
      default: true
    },{
      type: "confirm",
      name: 'usedocs',
      message: 'Add docker code doc generator?',
      default: true
    },{
      type: "confirm",
      name: 'readmebuildingblocks',
      message: 'Add building blocks description to README?',
      default: true
    }];

    this.prompt(prompts, function (props) {
      var promt,_i,_len;
      this.useserverviews = props.useserverviews = ( props.servertype === "GUI" ? true : false )
      if( !props.useserverviews ){
        props.usei18n = false
        props.useclientviews = false
      }
      if( !props.useredis ){
        props.usesessions = false
      }
      if( !props.usesessions ){
        props.addpassworlesslogin = false
        props.sessionappname = ""
      }
      console.log(props);
      // generic add of promt questions
      for (var _i = 0, _len = prompts.length; _i < _len; _i++) {
        promt = prompts[_i];
        if (props[promt.name] != null) {
          this[promt.name] = props[promt.name];
        }
      }

      var _d = new Date();
      this.todaydate = _d.getFullYear() + "-" + ( _d.getMonth() + 1 ) + "-" + _d.getDate()
      this.todayyear = _d.getFullYear()
      done();
    }.bind(this));
  },

  writing: {
    projectfiles: function () {
      this.template('_package.json', 'package.json');
      this.template('_Gruntfile.coffee', 'Gruntfile.coffee');
      this.template('_travis.yml', '.travis.yml');
      this.template('README.md');
    },

    configfiles: function () {
      this.src.copy('_gitignore', '.gitignore');
      this.src.copy('_npmignore', '.npmignore');
      this.src.copy('_editorconfig', '.editorconfig');
      this.template('_LICENSE.md', 'LICENSE.md' );
    },

    src: function () {
      this.dest.mkdir('_src');
      this.dest.mkdir('_src/lib');
      this.dest.mkdir('_src/model');
      this.dest.mkdir('_src/modules');
      this.dest.mkdir('_src/modules/rest');

      this.template('_src/server.coffee');
      
      this.template('_src/lib/apibase.coffee');
      this.template('_src/lib/config.coffee');
      this.template('_src/lib/request.coffee');
      this.template('_src/lib/utils.coffee');
      
      this.template('_src/model/_rest_tunnel.coffee');
      this.template('_src/model/users.coffee');
      if(this.useserverviews || this.usesessions){
        this.template('_src/modules/gui.coffee');
      }
      this.template('_src/modules/rest/restbase.coffee');
      this.template('_src/modules/rest/users.coffee');

      if(this.useredis){
        this.template('_src/lib/redisconnector.coffee');
      }
      if(this.addpassworlesslogin){
        this.template('_src/lib/passwordless.coffee');
      }
      
      if( this.usetests ){
        this.dest.mkdir('_src/test');
        this.template('_src/test/main_spec.coffee');
      }
    },
    src_static: function () {
      if(this.useserverviews){
        this.dest.mkdir('_src_static');

        this.dest.mkdir('_src_static/css');
        this.dest.mkdir('_src_static/css/styl');
        
        this.src.copy('_src_static/css/style.styl', '_src_static/css/style.styl');
        this.src.copy('_src_static/css/styl/globals.styl', '_src_static/css/styl/globals.styl');
        this.src.copy('_src_static/css/styl/general.styl', '_src_static/css/styl/general.styl');
        this.src.copy('_src_static/css/styl/bootstrap.styl', '_src_static/css/styl/bootstrap.styl');
        
        if(this.usesessions){
          this.src.copy('_src_static/css/login.styl', '_src_static/css/login.styl');
          this.src.copy('_src_static/css/styl/login.styl', '_src_static/css/styl/login.styl');
        }
        
        this.dest.mkdir('_src_static/js');
        this.template('_src_static/js/main.coffee');
        if(this.useclientviews){
          this.dest.mkdir('_src_static/js/lib');
          this.template('_src_static/js/lib/tmpls.coffee');

          this.dest.mkdir('_src_static/jst');
          this.src.copy('_src_static/jst/base-inherit.html', '_src_static/jst/base-inherit.html');
          this.src.copy('_src_static/jst/basic.html', '_src_static/jst/basic.html');
        }
        if(this.usesessions){
          this.template('_src_static/js/login.coffee', '_src_static/js/login.coffee');
        }

        this.dest.mkdir('_src_static/static');
        this.dest.mkdir('_src_static/static/img');
        this.src.copy('_src_static/static/img/bg.jpg', '_src_static/static/img/bg.jpg');
        this.src.copy('_src_static/static/img/logo.png', '_src_static/static/img/logo.png');
        this.src.copy('_src_static/static/img/logo_full.png', '_src_static/static/img/logo_full.png');
      }
    }
  },
  views: function(){
    if(this.useserverviews){
      this.dest.mkdir('views');
      this.dest.mkdir('views/layouts');
      this.dest.mkdir('views/components');

      this.template('views/index.html');
      this.template('views/404.html');
      this.template('views/layouts/main.html');
      this.template('views/components/_example_layout.html');
      this.template('views/components/example.html');
      
      if(this.usesessions){
        this.template('views/login.html');
        this.template('views/layouts/login.html');
      }
    }
  },
  end: function () {
    var _skipInst = this.options["skip-install"] || false;
    this.installDependencies( {
      bower: false,
      npm: true,
      skipInstall: _skipInst,
      callback: function () {
        if( !_skipInst ){
          this.spawnCommand('grunt', ['build-dev']);
        }
      }.bind(this)
    });
  }
});

module.exports = MpnodeappGenerator;
