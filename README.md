# generator-mpnodeapp [![Build Status](https://secure.travis-ci.org/mpneuried/generator-mpnodeapp.png?branch=master)](https://travis-ci.org/mpneuried/generator-mpnodeapp)

> [Yeoman](http://yeoman.io) generator

This is a generator to create a basic node.js app skeleton.

Optional features:

- serverside nunjucks views
- client nunjucks views
- i18n by gettext
- redis stubs
	- sessions by `connect-redis-sessions`
- test skeleton
- code docs
- README skeleton

## Getting Started

### What is Yeoman?

Trick question. It's not a thing. It's this guy:

![](http://i.imgur.com/JHaAlBJ.png)

Basically, he wears a top hat, lives in your computer, and waits for you to tell him what kind of application you wish to create.

Not every new computer comes with a Yeoman pre-installed. He lives in the [npm](https://npmjs.org) package repository. You only have to ask for him once, then he packs up and moves into your hard drive. *Make sure you clean up, he likes new and shiny things.*

```bash
npm install -g yo
```

### Yeoman Generators

Yeoman travels light. He didn't pack any generators when he moved in. You can think of a generator like a plug-in. You get to choose what type of application you wish to create, such as a Backbone application or even a Chrome extension.

To install generator-mpnodeapp from npm, run:

```bash
npm install -g generator-mpnodeapp
```

Finally, initiate the generator:

```bash
yo mpnodeapp
```

### Getting To Know Yeoman

Yeoman has a heart of gold. He's a person with feelings and opinions, but he's very easy to work with. If you think he's too opinionated, he can be easily convinced.

If you'd like to get to know Yeoman better and meet some of his friends, [Grunt](http://gruntjs.com) check out the complete [Getting Started Guide](https://github.com/yeoman/yeoman/wiki/Getting-Started).

## TODOS

## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|0.1.3|2015-01-29|removed prepublish script [npm#3059](https://github.com/npm/npm/issues/3059) and fixed travis.yml|
|0.1.2|2015-01-29|Default modulename by current folder|
|0.1.1|2015-01-29|Better `.npmignore and prepublish call for `grunt build-dev`; bugfixes|
|0.1.0|2014-12-05|Added caching stubs and optimized HRequest|
|0.0.2|2014-11-25|Fixed login form for disabled passwordless option|
|0.0.1|2014-11-24|Initial commit|

## License

MIT