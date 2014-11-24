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
      type: 'confirm',
      name: 'someOption',
      message: 'Would you like to enable this option?',
      default: true
    }];

    this.prompt(prompts, function (props) {
      this.someOption = props.someOption;

      done();
    }.bind(this));
  },

  writing: {
    app: function () {
      this.dest.mkdir('_src');
      this.dest.mkdir('_src_static');
      this.dest.mkdir('views');
      this.dest.mkdir('_locale');

      this.src.copy('_gitignore', '.gitignore');
      this.src.copy('_editorconfig', '.editorconfig');

      this.src.copy('_package.json', 'package.json');
      this.src.copy('_Gruntfile.coffee', 'Gruntfile.coffee');

      this.src.copy('LICENCE', 'LICENCE');


    },

    projectfiles: function () {
      this.src.copy('editorconfig', '.editorconfig');
      this.src.copy('jshintrc', '.jshintrc');
    }
  },

  end: function () {
    this.installDependencies();
  }
});

module.exports = MpnodeappGenerator;
