[![Build Status](https://travis-ci.org/tandrewnichols/task-master.png)](https://travis-ci.org/tandrewnichols/task-master) [![downloads](http://img.shields.io/npm/dm/task-master.svg)](https://npmjs.org/package/task-master) [![npm](http://img.shields.io/npm/v/task-master.svg)](https://npmjs.org/package/task-master) [![Code Climate](https://codeclimate.com/github/tandrewnichols/task-master/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/task-master)

# task-master

A helper to make Grunt task declaration and organization cleaner.

## Installation

`npm install task-master --save`

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

Step 3: Call task-master from your Gruntfile and pass it `grunt`. No need to call `initConfig` or `loadNpmTasks` as task-master does both for you. It will automatically load any plugins specified in package.json under devDependencies that begin with 'grunt-' (as that is the paradigm for publishing grunt tasks).

Gruntfile.js

```javascript
var taskMaster = require('task-master');

module.exports = function(grunt) {
  taskMaster(grunt);
  
  // register other tasks (like default) etc.
};
```

By default task-master reads your devDependencies looking for grunt plugins, but you can make it look it in your regular dependencies as well by passing an optional configuration object.

```javascript
var taskMaster = require('task-master');

module.exports = function(grunt) {
  taskMaster(grunt, {
    production: true, // Look in "dependencies" - default: false
    development: false // Don't look in "devDependencies" - default: true
  });
};
```

## Running tests

`git clone git@github.com:tandrewnichols/task-master.git`

`cd task-master`

`npm install`

`npm install mocha -g`

`npm test`
