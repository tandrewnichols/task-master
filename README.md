[![Build Status](https://travis-ci.org/tandrewnichols/task-master.png)](https://travis-ci.org/tandrewnichols/task-master) [![downloads](http://img.shields.io/npm/dm/task-master.svg)](https://npmjs.org/package/task-master) [![npm](http://img.shields.io/npm/v/task-master.svg)](https://npmjs.org/package/task-master) [![Code Climate](https://codeclimate.com/github/tandrewnichols/task-master/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/task-master) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/task-master/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/task-master) [![dependencies](https://david-dm.org/tandrewnichols/task-master.png)](https://david-dm.org/tandrewnichols/task-master)

[![NPM info](https://nodei.co/npm/task-master.png?downloads=true)](https://nodei.co/npm/task-master.png?downloads=true)

# task-master

A helper to make Grunt task declaration and organization cleaner.

## Installation

`npm install task-master --save-dev`

## Summary

`grunt.loadTasks` is a nice way to separate out tasks into separate files and keep your Gruntfile from getting hairy, but there's no clean way to do the same with configuration. This module is a (very) small wrapper that allows both tasks and configuration to be abstracted out of your Gruntfile into separate modules.

**NOTE: This is different than `taskmaster`, which is some sort of task runner written by someone who must not know that grunt exists.**

## Usage

Step 1: Define your tasks and configuration in separate files where the name of the file corresponds to the name of the task.

```
tasks
  jshint.js
  watch.js
  myCustomTask.js
```

Step 2: Export either a literal configuration object or a function that accepts `grunt` and returns a configuration object.

tasks/jshint.js

```javascript
module.exports = {
  options: {
    curly: true,
    eqeqeq: true
  },
  'default': '**/*.js'
};
```

tasks/watch.js

```javascript
module.exports = {
  js: {
    files: '**/*.js',
    tasks: 'jshint'
    options: {
      cwd: 'server'
    }
  }
};
```

tasks/myCustomTask.js

```javascript
module.exports = function(grunt) {
  // or registerMultiTask
  grunt.registerTask('myCustomTask', 'A task that does really neat stuff', function() {
    // The neat stuff...
  });
  return {
    options: {
      extraNeatness: true
    }
  };
};
```

Step 3: Call task-master from your Gruntfile and pass it `grunt`. No need to call `initConfig` or `loadNpmTasks` as task-master does both for you. By default, it will automatically load any plugins specified in package.json under devDependencies that begin with 'grunt-', but as of v2.0.0, this is all very customizable. See [options](#options) below.

Gruntfile.js

```javascript
var taskMaster = require('task-master');

module.exports = function(grunt) {
  taskMaster(grunt);
  
  // register other tasks (like default) etc.
};
```

## Options

As of v2.0.0, `task-master` accepts a configuration object. The possible values are as follows:

```javascript
dependencies: Boolean // include grunt plugins found under production dependencies (default false) - formerly "production"
devDependencies: Boolean // include grunt plugins found under development dependencies (default true) - formerly "development"
pattern: String or RegExp // grunt plugin name pattern (default /^grunt-/)
include: String or Array // specific plugins not matching the plugin pattern to include (default [])
exclude: String or Array // specific plugins matching the plugin pattern to exclude (default [])
tasks: String or Array // directories to load plugin tasks from (default 'tasks')
```

Here's an example:

```javascript
var tm = require('task-master');

module.exports = function(grunt) {
  tm(grunt, {
    dependencies: true, // load production dependencies
    devDependencies: false, // don't load development dependencies
    pattern: /^grunt-contrib-/, // only load grunt-contrib plugins
    include: ['foo-plugin', 'bar-plugin'], // include these plugins that don't match the pattern
    exclude: 'grunt-contrib-baz', // exclude this plugin which DOES match the pattern
    tasks: ['tasks', 'plugins'] // load plugins from multiple directories
  });
};
```

If you are only changing which set of dependencies to look at, you can also pass either 'dependencies' or 'devDependencies' as a string (as the second argument) and `task-master` will use that as the only plugin source (i.e. it turns "on" the one you pass in and turns "off" the other one).

```javascript
var tm = require('task-master');

module.exports = function(grunt) {
  tm(grunt, 'dependencies');
};
```

## Running tests

```bash
git clone git@github.com:tandrewnichols/task-master.git
cd task-master
npm install
npm install grunt-cli mocha -g
grunt or npm test
```
