[![Build Status](https://travis-ci.org/tandrewnichols/task-master.png)](https://travis-ci.org/tandrewnichols/task-master) [![downloads](http://img.shields.io/npm/dm/task-master.svg)](https://npmjs.org/package/task-master) [![npm](http://img.shields.io/npm/v/task-master.svg)](https://npmjs.org/package/task-master) [![Code Climate](https://codeclimate.com/github/tandrewnichols/task-master/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/task-master) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/task-master/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/task-master) [![dependencies](https://david-dm.org/tandrewnichols/task-master.png)](https://david-dm.org/tandrewnichols/task-master)

[![NPM info](https://nodei.co/npm/task-master.png?downloads=true)](https://nodei.co/npm/task-master.png?downloads=true)

# task-master

A helper to make Grunt task declaration and organization cleaner.

## Installation

`npm install task-master --save-dev`

## Summary

`grunt.loadTasks` is a nice way to separate out tasks into separate files and keep your Gruntfile from getting hairy, but there's no clean way to do the same with configuration. This module is a small wrapper that allows both tasks and configuration to be abstracted out of your Gruntfile into separate modules.

**NOTE: This is different than `taskmaster` (without the hyphen), which is some sort of task runner written by someone who must not know that grunt exists.**

## Usage

Step 1: Define your tasks and configuration in separate files where the name of the file corresponds to the name of the task. (Task-master can load `.js`, `.coffee`, `.json`, and `.yml`, so specify your configuration in whatever format you prefer. Obviously, however, if you need dynamic functionality, you'll need to use `.js` or `.coffee`.)

```
tasks
  jshint.js
  watch.js
  myCustomTask.js
```

Step 2: Export either a literal configuration object or a function that accepts `grunt` and `context` (more on context below)  and returns a configuration object.

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
  // You probably don't need to return configuration for tasks you write,
  // but you could use a function in a plugin's task configuration to do
  // different things based on the environment (for example)
  return {
    options: {
      extraNeatness: true
    }
  };
};
```

Additionally, as of version 2.2.0, you can even define target-specific configuration files in the form `tasks/<task>.<target>.{js,json,coffee,yml}`. If, for example, you have a really big `copy` task, you could break it out into target-specific files like `tasks/copy.dev.js` and `tasks/copy.dist.js`, which will result in a configuration object that looks like:

```javascript
{
  copy: {
    dev: {
      // exports of copy.dev.js
    },
    dist: {
      // exports of copy.dist.js
    }
  }
}
```

Incidentally, this will also work with task-level options, if you define (e.g.) a `tasks/copy.options.js.`

Step 3: Call task-master from your Gruntfile and pass it `grunt` and an optional options object. No need to call `initConfig` or `loadNpmTasks` as task-master does both for you.

Gruntfile.js

```javascript
var taskMaster = require('task-master');

module.exports = function(grunt) {
  taskMaster(grunt);
  
  // register other tasks (like default) etc.
};
```

If you are not passing any options, you can actually shorten this to:

```javascript
module.exports = require('task-master');
```

## Options

Task-master is highly configurable. You can pass any of the following options to change the default behavior.

### devDependencies

Indicates whether to load tasks from `devDependencies`. The default is true, and probably 99% of the time, that's what you want. I can't actually think of a time when you wouldn't want this to be true. Even if your grunt plugins are under `dependencies`, having this property set to true probably won't make a difference. But for completeness:

```javascript
taskMaster(grunt, { devDependencies: false });
```

### dependencies

Indicates whether to load tasks from `dependencies`. The default is false. Most of the time you don't need this, but there are some cases where you do, for instance for running builds on a heroku server (which runs `npm install --production` and therefore doesn't have access to `devDependencies`).

```javascript
taskMaster(grunt, { dependencies: true });
```

### peerDependencies

Load tasks from peerDependencies. Probably don't do this unless you have a really good reason.

```javascript
taskMaster(grunt, { peerDependencies: true });
```

### optionalDependencies

Load tasks from optionalDependencies. Again, this seems like a bad idea in general. But it's there . . . because if it's not, someone will undoubtedly want it and ask about it.

```javascript
taskMaster(grunt, { optionalDependencies: true });
```

### pattern

String or regex pattern for matching grunt plugins. Default is `/^grunt-/`.

```javascript
taskMaster(grunt, { pattern: /^grunt-contrib-`/ }); // or 'grunt-contrib-'
```

### include

Tasks to include that don't match the pattern. If you have one or two plugins to load that don't start with "grunt-" (do such plugins exist?), it's probably better to specify them here, rather than try to write a custom pattern that will match everything you need. This can be a string plugin name or an array of string plugin names.

```javascript
taskMaster(grunt, { include: ['not-grunt-foo', 'and-not-grunt-bar'] }); // or for one: { include: 'blah-blah' }
```

### exclude

Tasks to exclude that _do_ match the pattern. If you want to load all "grunt-" plugins, _except_ grunt-foo-bar, you can do that here. Again, this can be a string plugin name or an array of string plugin names.

```javascript
taskMaster(grunt, { exclude: ['grunt-foo-bar'] }); // or: { exclude: 'grunt-foo-bar' }
```

### ignore

Files in the directories from which tasks are loaded that should be ignored. Files that start with `_` are ignored by default, but you can specify other filenames (relative to the directory tasks are in) to leave out of the config. Again, this can be a string or an array.

```javascript
taskMaster(grunt, { ignore: 'configuration.json' });
```

### tasks

Directory or directories to load plugins from. Defaults to \<project_root\>/tasks. This can be a string or list of strings.

```javascript
taskMaster(grunt, { tasks: 'plugins' });
```

### context

Context is an object of additional properties that can be passed, which is used in a few places. It's passed to files in task directories that export functions. So if you want to use some configuration in `tasks/foo.js`, you can accept it as the second parameter:

```javascript
module.exports = function(grunt, context) {
  // Do stuff with context
};
```

More importantly, keys under context are added to your grunt config at the top level. So if you, for instance, like having access to your package.json contents in your config, you can pass it under context:

```javascript
taskMaster(grunt, { context: { pkg: require('./package') } });
```

Then you can use it in your interpolation as normal:

```javascript
{
  files: {
    'dist/<%= pkg.name %>.min.js': './src/main.js'
  }
}
```

This is also useful if you reuse file patterns all over the place. Just add a `files` key under context and access them with:

`<%= files.js.vendor %>`

### alias

An object of aliases to add to grunt, where the key is the alias name and the value is the tasks to run.

```javascript
taskMaster(grunt, {
  alias: {
    default: ['jshint', 'mocha:all'],
    build: ['clean:dist', 'concat:dist', 'uglify:dist']
  }
});
```

### jit

As of version 2.2.0, `task-master` will delegate to `jit-grunt` for loading npm grunt plugins (which incidentally makes the "dependency" options above unnecessary, since `jit-grunt` loads from `node_modules` regardless of where in the package a dependency is defined), which can significantly speed up your build time. If you don't want to use `jit-grunt`, you can pass `jit: false`, and `task-master` will load in the way it did prior to 2.2.0. But there's basically no reason you should want to do this. Alternatively, you can pass jit as an object, and that object will be passed into `jit-grunt` as the [static-mappings](https://github.com/shootaroo/jit-grunt#static-mappings). So you can do something like this:

```javascript
taskMaster(grunt, {
  jit: {
    ngtemplates: 'grunt-angular-templates',
    spec: 'grunt-jasmine-bundle'
  }
});
```

## Loading from files

But the really cool thing about task-master is that you can load some of these options from files by passing a string file path (or a list of string file paths) instead of a literal object. You can even pass globstar patterns. You can load the entire options object, the context, or the aliases from a file. The following examples assume you are using the default tasks directory:

```javascript
// loads the options object from \<project_root\>/tasks/_opts.json
taskMaster(grunt, '_opts.json');
```

```javascript
// loads aliases from \<project_root\>/tasks/_aliases.json AND \<project_root\>/tasks/_alias.js
taskMaster(grunt, { aliases: ['_aliases.json', '_alias.json'] });
```

```javascript
// loads a context object from \<project_root\>/tasks/_context.json
// and any files in \<project_root\>/tasks that start with "_context."
// and end with ".json"
taskMaster(grunt, { context: ['_context.json', '_context.*.json'] });
```

These files can be `.js`, `.coffee`, `.json`, or `.yaml` files. If they export a function, it will be invoked, which let's you programmatically determine the results. E.g.:

```javascript
// In an alias file
module.exports = function() {
  // Except . . . do something dynamic here
  return {
    default: ['jshint', 'mocha:all'],
    build: ['clean:dist', 'concat:dist', 'uglify:dist']
  };
};
```

The results of these files will be merged into a single object.

But it gets even better. Because I think you shouldn't have to pass a huge messy configuration object (that's exactly what this library is trying to _undo_) you can load content from files automatically if they have specific, canonical names. Just add a `"_taskmaster.opts*.{js,coffee,json,yml}"` to your tasks directory (or wherever you load plugins from), and it will automatically be loaded as your options. Add a `"_taskmaster.context*.{js,coffee,json,yml}"` for your context and a `"_taskmaster.alias*.{js,coffee,json,yml}"` for your aliases. And see that star hiding in the middle there? That means you can even create multiple canonical files as long as they match that pattern.

Why would you want to load configuration from multiple files you ask? I'm envisioning a team scenario where some members of the team might want to (for example) define their own task aliases that aren't part of the normal aliases. So you have a `_taskmaster.alias.json` file for all the common aliases, and then pop this in your `.gitignore`:

`tasks/_aliases.json`

Now each member can add their own aliases without interfering with other members. Don't like typing `grunt mochaTest`, which is the task name in the main aliases file? Just add a `tasks/_aliases.json` that looks like this:

```javascript
var grunt = require('grunt');

module.exports = function() {
  grunt.renameTask('mochaTest', 'mocha');
  return {
    test: ['mocha'],
    w: ['build', 'doStuff', 'mocha', 'watch']
  };
};
```

You can add your own short hand aliases or combinations of tasks for testing purposes.

## Overrides

As an extension of the alias overriding above, you can override task configuration by create `_taskmaster.override.<task>.{js,json,coffee,yml}` files. For instance, if you have a `tasks/copy.js`, you can add a `_taskmaster.override.copy.js` and the override exports will be merged into the regular configuration, with the overrides taking precedence. This feature is primarily for teams, so that you can add `tasks/_taskmaster.override.*` to your `.gitignore` and then setup developer-specific configuration that doesn't have to be shared by the team.

## A Note on Context

The canonical context file path is included for completeness and uniformity, but astute readers will note that it is not actually necessary, since `task-master` merges files in with the filename as a property at the top level of the grunt config. This means that creating a `tasks/files.js` will have the same effect as creating a `_taskmaster.context.js` file that exports a `files` object. Which you choose will mostly depend on taste and whether you like breaking things up into smaller files or keeping everything of the same type together.

## Running tests

```bash
git clone git@github.com:tandrewnichols/task-master.git
cd task-master
npm install
npm install grunt-cli mocha -g
grunt or npm test
```
