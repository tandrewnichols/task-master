#!/usr/bin/env node

var program = require('commander');
var coercion = require('./cli/coercion');
var actions = require('./cli/actions');
var _ = require('lodash');
_.mixin(require('safe-obj'));

program
  .version(require('./package').version)
  .usage('<command> [target] [options]');

program.name = 'task-master';

program
  .command('init')
  .description('Create a gruntfile that use task-master')
  .option('-d, --dependencies', 'Add grunt plugins from production dependencies')
  .option('-D, --no-dev-dependencies', 'Do not add grunt plugins from development dependencies')
  .option('-p, --pattern <pattern>', 'Pattern for matching grunt plugins', coercion.toRegex, /^grunt-/)
  .option('-i, --include <plugin>', 'Plugins to include', coercion.collect, [])
  .option('-e, --exclude <plugin>', 'Plugins to ignore', coercion.collect, [])
  .option('-t, --task-dir <path>', 'Directory/directories containing grunt tasks or configuration', coercion.collect, [])
  .option('-c, --coffee', 'Generate Gruntfile.coffee instead of Gruntfile.js')
  .option('--tabstop <number>', 'Set the indentation level for generated files', coercion.toSpacing, 2)
  .option('--no-expand-tab', 'Use tabs instead of spaces')
  .action(actions.init);

console.log(process.argv);
if (~process.argv[1].indexOf('task')) {
  program.parse(process.argv);
}

module.exports = program;
