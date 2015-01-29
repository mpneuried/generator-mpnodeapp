# <%= appname %>

<% if(readmebuildingblocks){ %>
## General Information

Please don't add *.js files compiled from coffee, node_modules, etc.

## Building Blocks

#### Build Tool

The build tool is **[Grunt](http://gruntjs.com/)**. It allows to compile, generate, prepare and minify all source files.  
For mor info see the section **Developement**.

#### JS

All Javascript is written in **[Coffescript](http://coffeescript.org/)**.  
So within the repository there should not exist any `.js` file.  
The Files are compiled by the grunt build process and during development on each file change.  
Coffee files are located in `_src/`. The compiler builds up the same folder structure.
<% if( useserverviews ){ %>
#### CSS

All CSS is written in **[Stylus](http://learnboost.github.io/stylus/)**.
So within the repository there should not exist any `.css` file.  
The Files are compiled by the grunt build process and during development on file change.  
Main Stylus files are located in `_src_static/css/`.  
All subfiles, which are imported via `@import( "./styl/foo" )` to the main files, are located in `_src_static/css/styl/`

<% } %>
<% if(useserverviews || useclientviews){ %>
#### Templates

As template engine Mozilla's **[Nunjucks](http://mozilla.github.io/nunjucks/)** is used.
It's widely compatible with [Jinja2](http://jinja.pocoo.org/docs/dev/) or [Django templates](https://docs.djangoproject.com/en/dev/topics/templates/) for Python, [Twig](http://twig.sensiolabs.org/) for PHP, [Liquid](http://liquidmarkup.org/) for Ruby.  
<% if(useserverviews){ %>All server side template files are located in `views/` and cann be called in express by `res.render( 'index' )`.  <% } %>
<% if(useclientviews){ %>The client side templates are located in `_src_static/jst/` and are precompiled.<% } %>

<% } %>
#### Server Code

The HTTP Server is a **[Node.JS](http://nodejs.org)** based **[Express](http://expressjs.com/)** server.
All external dependencies are described in `package.json` and processed by [NPM](https://www.npmjs.org/)

<% if( usei18n ){ %>
#### Localisation/Translation

To be able to translate all texts within this project we are using the standard **getext** pattern togethert with **.PO** files.
A grunt script will extract the `gettext("Foo")` calls within the templates, merge with the translated files and compile them to JSON files. This is all be done by the module `grunt-18n-abide` and used in express by `i18n-abide`.  
To start the extract/merge/compile process just call `grunt build_i18n`.  
The server Po-file sources with all the text are located in `_locale/[LANG]/LC_MESSAGES`.  
The client Po-file sources with all the text are located in `_src_static/locale/[LANG]/LC_MESSAGES`.  
To add a new language you can just add the language-Code to the array `languageCodes` within the `Gruntfile.coffee`.  
To edit the po files you can use a editor like [poedit](https://poedit.net/download) or this [online-tool](https://localise.biz/free/poedit).

<% } %>
<% } %>
## Install

Make sure you have installed the grunt client `npm install -g grunt-cli`.

```
npm install
grunt build
```

<% if( usei18n ){ %>
#### translations

If you want to develop with translations you will have to install `gettext` via **[homebrew]{http://brew.sh}**.
This is done by just calling `brew install gettext` after you installed homebrew.

After that you'll have to check the path to to binary's of **gettext**.
The default in grunt is `/usr/local/opt/gettext/bin/`. If yor path differs you have to set the configuration `grunt.gettext_path`.

To run a complete build with translation call:

```
	grunt build_i18n
```

If you only want to build the translation files call:

```
	grunt i18n
```

<% } %>
<% if( usedocs ){ %>
#### Code Docs

To document the code the module **[docker.js](http://jbt.github.io/docker/src/docker.js.html)** is used.

To regenerate the docs just call

```
grunt docs
```

This will regenrate the code docs to the `_docs` folder.

<% } %>
### Configuration

To change your local configuration add a file `config.json` to the root.
Within this file every key is optional

**Example:**

```
{
	"server": {
		"port": <%= expressport %>
	}
}
```

#### Relevant configurations

* **server** *( `Object` )*: server configuration.
	* **port** *( `Number` [ default: `<%= expressport %>` ])*: The port the server will listen to.
	* **basepath** *( `String` [ default: `/` ])*: Path prefix for all routes.
	* **appname** *( `String` [ default: `<%= sessionappname %>` ])*: The app name. Used as `redis-session` namespace.
* **selfLink** *( `String` [ default: `http://localhost:<%= expressport %>/` ] )* The link to the running server. E.g. used to generate the passwordless token-link.
* **express** *( `Object` )*: Express configuration.
	* **logger** *( `String` [ default: `dev` ])*: Express logger config.
	* **staticCacheTime** *( `Number` [ default: `2678400000` ])*: Caching time for static content. Default is 31 days.<% if( useredis ){ %>
* **redis** *( `Object` )*: Redis configuration.
	* **host** *( `String` [ default: `localhost` ])*: Redis server
	* **port** *( `Number` [ default: `6379` ])*: Redis port
	* **options** *( `Object` [ default: `{}` ])*: Redis options<% } %><% if( usei18n ){ %>
* **grunt** *( `Object` )*: Grunt configrations. This will not used by the server.
	* **gettext_path** *( `String` [ default: `/usr/local/opt/gettext/bin/` ])*: Path to your `gettext` binarys to develop translation.<% } %>


> More to come


### Run

To start the server just call

```
node server.js
```

### Development

It's recommened to use a tool like `node-dev` ( `npm install -g node-dev` ) for developement wich restarts the server on a file change.
Also you have 

**Start server**

```
node-dev server.js
```

Now you can use the grunt watcher to generate the project files on every source change.

```
grunt watch
```

Before you commit your code it's recommeded to call

```
grunt build-dev
```

This task will build all files<% if( usei18n ){ %>, process the language files<% } %> and updates the code docs
<% if( usedocs ){ %>
#### Code documentation

The code docu will be generated by `grunt docs`.
This will pass all source files through [docker.js](http://jbt.github.io/docker/src/docker.js.html) witch will generate the docs to the folder `/_docs`.

Make shure the linking between the files are working well.
To document the methods of a class please use the [jsdoc-toolkit pattern](https://code.google.com/p/jsdoc-toolkit/w/list). 

<% } %>
## TODOS


## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|<%= appversion %>|<%= todaydate %>|Initial commit|

> Initially Generated with [generator-mpnodeapp](https://github.com/mpneuried/generator-mpnodeapp)

## The MIT License (MIT)

Copyright © <%= todayyear %> [<%=githubuser %>](https://github.com/<%=githubuser %>)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
