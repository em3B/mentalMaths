const { environment } = require('@rails/webpacker');
const path = require('path');

// Extend Webpack configuration to handle polyfills and resolve paths
environment.config.merge({
  entry: {
    main: './app/javascript/application.js',  // Specify your main entry point
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'public/packs'),
  },
  resolve: {
    // Alias modules for compatibility with older Webpack
    alias: {
      path: require.resolve('path-browserify'),
      os: require.resolve('os-browserify/browser'),
      util: require.resolve('util/'),
      zlib: require.resolve('browserify-zlib'),
    },
  },
  node: {
    fs: 'empty',
    net: 'empty',
    tls: 'empty',
    dgram: 'empty',
    child_process: 'empty',
  },
});

module.exports = environment;
