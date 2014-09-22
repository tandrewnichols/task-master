var tm = require('task-master');

module.exports = function(grunt) {
<%= space %>tm(grunt, {
<% if (dependencies) { %>
<%= space %><%= space %>dependencies: <%= dependencies %>,
<% } %>
<% if (!devDependencies) { %>
<%= space %><%= space %>devDependencies: <%= devDependencies %>,
<% } %>
<% if (pattern) { %>
<%= space %><%= space %>pattern: <%= pattern %>,
<% } %>
<% if (include.length) { %>
<%= space %><%= space %>include: [ <% print(include.join(', ')) %> ],
<% } %>
<% if (exclude.length) { %>
<%= space %><%= space %>exclude: [ <% print(exclude.join(', ')) %> ],
<% } %>
<% if (taskDir.length) { %>
<%= space %><%= space %>tasks: [ <% print(taskDir.join(', ')) %> ]
<% } %>
<%= space %>});
};
