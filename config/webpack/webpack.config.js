const { generateWebpackConfig, baseConfig } = require('shakapacker');
const entrypoints = require('./entrypoints');
const webpack = require('webpack'); 

const config = { ...baseConfig };

// Set entrypoints
config.entry = {};
for (const [name, paths] of Object.entries(entrypoints)) {
  config.entry[name] = Array.isArray(paths) ? paths : [paths];
}

// Ensure resolve exists
config.resolve = config.resolve || {};
config.resolve.fallback = {
  ...(config.resolve.fallback || {}),
  vm: require.resolve('vm-browserify'),
  path: require.resolve('path-browserify'), 
  crypto: require.resolve('crypto-browserify'),
  stream: require.resolve('stream-browserify'),
  buffer: require.resolve('buffer'),
  util: false,
  url: require.resolve('url/'),
  process: require.resolve('process/browser'),
  zlib: require.resolve('browserify-zlib'), 
  https: require.resolve('https-browserify'),
  http: require.resolve('stream-http'),
  tty: require.resolve('tty-browserify'),
  fs: false,
  querystring: require.resolve('querystring-es3'),
  module: false,
  tls: false,
  assert: require.resolve('assert/'),
  os: require.resolve('os-browserify/browser'),
  worker_threads: false,
  constants: require.resolve('constants-browserify'),
  child_process: false,
  net: false,
  '@swc/core': false,
  '@swc/wasm': false,
  esbuild: false,
  inspector: false,
};

config.plugins = config.plugins || [];
config.plugins.push(
  new webpack.ProvidePlugin({
    Buffer: ['buffer', 'Buffer'],
    process: 'process/browser',
  })
);

config.stats = {
  errorDetails: true,
};

module.exports = generateWebpackConfig(config);