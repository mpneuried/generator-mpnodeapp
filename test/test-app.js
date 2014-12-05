/*global describe, beforeEach, it*/
'use strict';

var path = require('path');
var assert = require('yeoman-generator').assert;
var helpers = require('yeoman-generator').test;
var os = require('os');

describe('mpnodeapp:app', function () {
  describe('default', function () {
    before(function (done) {
      helpers.run(path.join(__dirname, '../app'))
        .inDir(path.join(os.tmpdir(), './temp-test-testmodule-default'))
        .withOptions({ 'skip-install': true })
        .withPrompt({
          appname: "testmodule-default"
        })
        .on('end', done);
    });

    it('creates files', function () {
      assert.file([
        'package.json',
        'Gruntfile.coffee',
        '.travis.yml',
        'README.md',
        '.gitignore',
        '.editorconfig',
        'LICENSE.md',
        '_src/server.coffee',
        '_src/lib/apibase.coffee',
        '_src/lib/config.coffee',
        '_src/lib/request.coffee',
        '_src/lib/utils.coffee',
        '_src/lib/cache.coffee',
        '_src/model/_rest_tunnel.coffee',
        '_src/model/users.coffee',
        '_src/modules/gui.coffee',
        '_src/modules/rest/restbase.coffee',
        '_src/modules/rest/users.coffee',
        '_src/lib/redisconnector.coffee',
        '_src/lib/passwordless.coffee',
        '_src/test/main_spec.coffee',
        '_src_static/css/style.styl',
        '_src_static/css/styl/globals.styl',
        '_src_static/css/styl/general.styl',
        '_src_static/css/styl/bootstrap.styl',
        '_src_static/css/login.styl',
        '_src_static/css/styl/login.styl',
        '_src_static/js/main.coffee',
        '_src_static/js/lib/tmpls.coffee',
        '_src_static/js/login.coffee',
        '_src_static/css/styl/login.styl',
        '_src_static/static/img/bg.jpg',
        '_src_static/static/img/logo.png',
        '_src_static/static/img/logo_full.png',
        '_src_static/jst/base-inherit.html',
        '_src_static/jst/basic.html',
        'views/index.html',
        'views/404.html',
        'views/layouts/main.html',
        'views/components/_example_layout.html',
        'views/components/example.html',
        'views/login.html',
        'views/layouts/login.html'
      ]);
    });
    it('file content', function () {
      assert.fileContent('README.md', new RegExp( "# testmodule-default", "gi" ) );
      assert.fileContent('_src/server.coffee', new RegExp( "nunjucksEnv", "gi" ) );
      assert.fileContent('_src/server.coffee', new RegExp( "i18n\.abide", "gi" ) );
      assert.fileContent('_src/server.coffee', new RegExp( "ConnectRedisSessions", "gi" ) );
    });
  });
  describe('minimal', function () {
    before(function (done) {
      helpers.run(path.join(__dirname, '../app'))
        .inDir(path.join(os.tmpdir(), './temp-test-testmodule-min'))
        .withOptions({ 'skip-install': true })
        .withPrompt({
          githubuser: 'username',
          appname: 'testmodule-min',
          appdesc: 'App description ...',
          appversion: '0.0.1',
          minnodeversion: '0.10.0',
          isprivate: false,
          expressport: '3000',
          servertype: "only-REST",
          useclientviews: false,
          usei18n: false,
          useredis: false,
          usecache: false,
          usesessions: false,
          addpassworlesslogin: false,
          sessionappname: "xxx",
          usetests: false,
          usedocs: false,
          readmebuildingblocks: false
        })
        .on('end', done);
    });

    it('creates files', function () {
      assert.file([
        'package.json',
        'Gruntfile.coffee',
        '.travis.yml',
        'README.md',
        '.gitignore',
        '.editorconfig',
        'LICENSE.md',
        '_src/server.coffee',
        '_src/lib/apibase.coffee',
        '_src/lib/config.coffee',
        '_src/lib/request.coffee',
        '_src/lib/utils.coffee',
        '_src/model/_rest_tunnel.coffee',
        '_src/model/users.coffee',
        '_src/modules/rest/restbase.coffee',
        '_src/modules/rest/users.coffee'
      ]);
      assert.noFile([
        '_src/modules/gui.coffee',
        '_src/lib/redisconnector.coffee',
        '_src/lib/passwordless.coffee',
        '_src/test/main_spec.coffee',
        '_src_static/js/lib/tmpls.coffee',
        '_src/lib/cache.coffee',
        '_src_static/js/login.coffee',
        '_src_static/css/styl/login.styl',
        '_src_static/jst/base-inherit.html',
        '_src_static/jst/basic.html',
        '_src_static/css/login.styl',
        '_src_static/css/styl/login.styl',
        '_src_static/css/style.styl',
        '_src_static/css/styl/globals.styl',
        '_src_static/css/styl/general.styl',
        '_src_static/css/styl/bootstrap.styl',
        '_src_static/js/main.coffee',
        '_src_static/static/img/bg.jpg',
        '_src_static/static/img/logo.png',
        '_src_static/static/img/logo_full.png',
        'views/index.html',
        'views/404.html',
        'views/layouts/main.html',
        'views/components/_example_layout.html',
        'views/components/example.html',
        'views/login.html',
        'views/layouts/login.html'
      ]);
    });
    it('file content', function () {
      assert.fileContent('README.md', new RegExp( "# testmodule-min", "gi" ) );
      assert.noFileContent('_src/server.coffee', new RegExp( "nunjucksEnv", "gi" ) );
      assert.noFileContent('_src/server.coffee', new RegExp( "i18n\.abide", "gi" ) );
      assert.noFileContent('_src/server.coffee', new RegExp( "ConnectRedisSessions", "gi" ) );
      assert.noFileContent('_src/model/_rest_tunnel.coffee', new RegExp( "cacheGet", "gi" ) );
    });
  });


});
