module.exports = {
  v4: {
    test: function() {
      return /^v4/.test(process.version);
    },
    tasks: ['istanbul:cover', 'shell:codeclimate']
  }
};
