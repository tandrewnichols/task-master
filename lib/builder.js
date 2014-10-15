var _ = require('lodash');
var loader = require('./loader');
var fm = require('file-manifest');
var extend = require('config-extend');

/**
 * Gets the options, either passed in or from a file
 * @param {string} root - The project root
 * @param {string|Object} opts - An options object, a file path for opts, or null
 */
exports.buildOpts = function(root, opts) {
  opts = opts || {};
  var tasks = opts.tasks = opts.tasks || [ 'tasks' ];

  // Load options etc. from files if they are strings
  opts = loader.load('opts', opts, root, tasks, true); 
  opts.context = loader.load('context', opts.context, root, tasks);
  opts.alias = loader.load('alias', opts.alias, root, tasks);

  return exports.merge(opts);
};

/**
 * Merge the options object with the defaults
 * @param {Object} opts - The option overrides
 */
exports.merge = function(opts) {
  // Merge efault options
  var options = _.extend({}, {
    devDependencies: true,
    dependencies: false,
    optionalDependencies: false,
    peerDependencies: false,
    pattern: /^grunt-/,
    include: [],
    exclude: [],
    ignore: [],
    tasks: ['tasks']
  }, opts);

  // Make sure pattern is a regex
  if (!_.isRegExp(options.pattern)) {
    options.pattern = new RegExp(options.pattern);
  }

  // Make string options into arrays
  _.each(['tasks', 'include', 'exclude', 'ignore'], function(key) {
    options[key] = _.isArray(options[key]) ? options[key] : [options[key]];
  });

  return options;
};

/**
 * Build the grunt configuration
 * @param {string} root - The project root
 * @param {Object} options - Task-master options
 * @param {Object} grunt - Grunt
 */
exports.buildConfig = function(root, options, grunt) {
  var config = {};
  // Assign context keys directly to config
  for (var k in (options.context || {})) {
    config[k] = options.context[k];
  }

  // Add any ignored files to the file-manifest pattern
  var patterns = ['**/*.{js,coffee,json,yml}', '!**/_*.*'];
  _.each(options.ignore, function(file) {
    patterns.push('!' + file);
  });

  // Iterate over each task directory and build out
  // the grunt config using the results
  _.each(options.tasks, function(dir) {
    config = fm.generate(root + '/' + dir, {
      memo: config,
      patterns: patterns,
      reducer: function(opts, manifest, file) {
        // Get main task config
        var contents = loader.get(file.fullPath, grunt, manifest);
        // Get any config overrides
        var overrides = loader.load('override.' + file.name, null, root, [dir]);

        if (contents) {
          // Assign task configuration, recursively, to main config object
          exports.assignManifest(file.name, contents, manifest);
        }
        
        // Override configuration if provided
        var overrideConfig = {};
        if (!_.isEmpty(overrides)) {
          overrideConfig[file.name] = overrides;
        }

        // Merge the overrides into the main config.
        return extend(manifest, overrideConfig);
      }
    });
  });

  return config;
};

/**
 * Handles files of the type <task>.<target>.js
 * @param {String} name - The file name
 * @param {Object} contents - The file configuration
 * @param {Object} manifest - The current config manifest
 */
exports.assignManifest = function(name, contents, manifest) {
  var parts = name.split('.');
  var task = parts[0];
  var target = parts[1];
  var obj = {};

  // If we have a target-specific file, make a new object
  // with that key, otherwise use the whole config
  if (target) {
    obj[target] = contents;
  } else {
    obj = contents;
  }

  // If this task already exists in the config, extend
  if (manifest[task]) {
    extend(manifest[task], obj);
  } else {
    manifest[task] = obj;
  }
};
