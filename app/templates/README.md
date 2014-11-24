# MyMilon

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

#### CSS

All CSS is written in **[Stylus](http://learnboost.github.io/stylus/)**.
So within the repository there should not exist any `.css` file.  
The Files are compiled by the grunt build process and during development on file change.  
Main Stylus files are located in `_src_static/css/`.  
All subfiles, which are imported via `@import( "./styl/foo" )` to the main files, are located in `_src_static/css/styl/`

#### Templates

As template engine Mozilla's **[Nunjucks](http://mozilla.github.io/nunjucks/)** is used.
It's widely compatible with [Jinja2](http://jinja.pocoo.org/docs/dev/) or [Django templates](https://docs.djangoproject.com/en/dev/topics/templates/) for Python, [Twig](http://twig.sensiolabs.org/) for PHP, [Liquid](http://liquidmarkup.org/) for Ruby.  
All server side template files are located in `views/` and cann be called in express by `res.render( 'index' )`.  
The client side templates are located in `_src_static/jst/` and are precompiled.

#### Server Code

The HTTP Server is a **[Node.JS](http://nodejs.org)** based **[Express](http://expressjs.com/)** server.
All external dependencies are described in `package.json` and processed by [NPM](https://www.npmjs.org/)

#### Localisation/Translation

To be able to translate all texts within this project we are using the standard **getext** pattern togethert with **.PO** files.
A grunt script will extract the `gettext("Foo")` calls within the templates, merge with the translated files and compile them to JSON files. This is all be done by the module `grunt-18n-abide` and used in express by `i18n-abide`.  
To start the extract/merge/compile process just call `grunt build_i18n`.  
The server Po-file sources with all the text are located in `_locale/[LANG]/LC_MESSAGES`.  
The client Po-file sources with all the text are located in `_src_static/locale/[LANG]/LC_MESSAGES`.  
To add a new language you can just add the language-Code to the array `languageCodes` within the `Gruntfile.coffee`.  
To edit the po files you can use a editor like [poedit](https://poedit.net/download) or this [online-tool](https://localise.biz/free/poedit).

## Install

Make sure you have installed the grunt client `npm install -g grunt-cli`.

```
npm install
grunt build
```

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

#### Code Docs

To document the code the module **[docker.js](http://jbt.github.io/docker/src/docker.js.html)** is used.

To regenerate the docs just call

```
grunt docs
```

This will regenrate the code docs to the `_docs` folder.

### Configuration

To change your local configuration add a file `config.json` to the root.
Within this file every key is optional

**Example:**

```
{
	"restTunnel": {
		"dataBasePath": "http://localhost:3002"
	}
}
```

#### Relevant configurations

* **server** *( `Object` )*: server configuration.
	* **port** *( `Number` [ default: `3008` ])*: The port the mymilon-server will listen to.
	* **basepath** *( `String` [ default: `/` ])*: Path prefix for all routes.
	* **appname** *( `String` [ default: `milon-mymilon` ])*: The app name. Used as `redis-session` namespace.
* **selfLink** *( `String` [ default: `http://localhost:3008/` ] )* The link to the running server. E.g. used to generate the passwordless token-link.
* **express** *( `Object` )*: Express configuration.
	* **logger** *( `String` [ default: `dev` ])*: Express logger config.
	* **staticCacheTime** *( `Number` [ default: `2678400000` ])*: Caching time for static content. Default is 31 days.
* **restTunnel** *( `Object` )*: Rest Tunnel configuration.
	* **dataBasePath** *( `String` [ default: `http://localhost:3002` ])*: Base url to the milon data-api
* **redis** *( `Object` )*: Redis configuration.
	* **host** *( `String` [ default: `localhost` ])*: Redis server
	* **port** *( `Number` [ default: `6379` ])*: Redis port
	* **options** *( `Object` [ default: `{}` ])*: Redis options
* **grunt** *( `Object` )*: Grunt configrations. This will not used by the server.
	* **gettext_path** *( `String` [ default: `/usr/local/opt/gettext/bin/` ])*: Path to your `gettext` binarys to develop translation.


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

This task will build all files, process the language files and updates the code docs

#### Server Development

**Folder-Struckture + important files**

* **`_src/lib/`**: General modules like config, utils, request, ...
	* `_src/lib/config.coffee`: The configuration module with all the relevant config options.
	* `_src/lib/utils.coffee`: Small utils and helpers.
	* `_src/lib/request.coffee`: Module to provided a reduced api of the popular request module on top of hyperquest
	* `_src/lib/redisconnector.coffee`: Basic module to extend. It handles a redis connection.
	* `_src/lib/apibase.coffee`: Basic Express methods.
* **`_src/model/`**: Data models to read Data from the data API
	* `_src/lib/_rest_tunnel.coffee`: Basic class to handle the call to the data-api.
* **`_src/modules/`**: General Express modules
	* `_src/modules/gui.coffee`: Handle the routes to render the GUI by express and handle the login.
	* **`_src/modules/rest/`**: all api express modules. Usually connected to a model
		* `_src/modules/rest/restbase.coffee`: Base class for api modules.
* **`_src/test/`**: REST tests by [frisby](http://frisbyjs.com)
* `_src/server.coffee`: Express server config. Add modules to the express server and start listening
* **`views/`**: Server rendered templates
* **`views/components/`**: Template submodules. Usually used with `{% include "components/???.html" %}`. The templates in this folder will also be availible within the client. So this is a shared template folder.
* **`_locale/`**: Here the PO and POT files extracted from the server-side templates will be placed.
* `_locale/{lang}/LC_MESSAGES/messages.po`: For every `{lang}` ( eg: *en*, *en_GB*, *de* ) a `messages.po` file will be generated. The translation tool should edit these files.

#### Client Develeopment

**Folder-Struckture + important files**

* **`_src_static/css`**: Stylus source files
	* **`_src_static/css/styl`**: Stylus submodules
		* `_src_static/css/styl/globals.styl`: Stlye globals like colors, sizes, fonts, ...
		* `_src_static/css/styl/general.styl`: Main stlyes for header, html elements, ...
		* `_src_static/css/styl/bootstrap.styl`: Overwrite bootstrap styles
	* `_src_static/css/login.styl`: Collection of submodules for the login site. Only imports should exist in this file.
	* `_src_static/css/style.styl`: Collection of submodules for the general mymilon site. Only imports should exist in this file.
* **`_src_static/js`**: Coffee source files
	* **`_src_static/js/lib`**: General library modules
		* `_src_static/js/lib/tmpls.coffee`: Handling of templates and translations.
	* **`_src_static/js/modules`**: Sub modules for every tile.
	* `_src_static/js/login.coffee`: Scripts for the login site
	* `_src_static/js/main.coffee`: Initializing for the main page.
* **`_src_static/jst`**: JS-Templates written in nunjucks.
* **`_src_static/static`**: All folders and files will be mirrored in the compiled `/static` folder.
* **`_src_static/static/img`**: images folder.
* **`views/components/`**: Template submodules. Usually used with `{% include "components/???.html" %}`. The templates are availible by the prefix `components/`. The templates in this folder will also be availible within the server. So this is a shared template folder.
* **`_src_static/locale/`**: Here the PO and POT files extracted from the client-side templates will be placed.
* `_src_static/locale/{lang}/LC_MESSAGES/messages.po`: For every `{lang}` ( eg: *en*, *en_GB*, *de* ) a `messages.po` file will be generated. The translation tool should edit these files.

#### Code documentation

The code docu will be generated by `grunt docs`.
This will pass all source files through [docker.js](http://jbt.github.io/docker/src/docker.js.html) witch will generate the docs to the folder `/_docs`.

Make shure the linking between the files are working well.
To document the methods of a class please use the [jsdoc-toolkit pattern](https://code.google.com/p/jsdoc-toolkit/w/list). 

## TODOS

### Skeleton *(TCS-MP)*

* documentation of basic files
* add clientside `gettext()` handling
* add token login
* add action recorder
* Frontend dev docs