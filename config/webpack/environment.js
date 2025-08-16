const { env, generateWebpackConfig } = require('shakapacker');
const entrypoints = require('./entrypoints');
const webpack = require('webpack');

// Clear existing entries
const entryPoints = env.config.entryPoints;
for (const entry of entryPoints.entries()) {
  entryPoints.delete(entry[0]);
}

// Add your custom entry points
for (const [name, paths] of Object.entries(entrypoints)) {
  env.config.entry(name).add(paths);
}

// Add fallback config
env.config.set('resolve.fallback', {
  ...(env.config.get('resolve.fallback') || {}),
  crypto: require.resolve('crypto-browserify'),
  url: require.resolve('url/'),
  path: require.resolve('path-browserify'),
  stream: require.resolve('stream-browserify'),
  buffer: require.resolve('buffer'),
  assert: require.resolve('assert'),
  util: require.resolve('util/'),
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
  esbuild: false,
  inspector: false,
});

env.config.set('optimization.minimize', false);

env.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    process: 'process/browser',
    Buffer: ['buffer', 'Buffer'],
  })
);

env.config.set('module.rules', [
  ...(env.config.get('module.rules') || []),

  // Ignore native .node files
  {
    test: /\.node$/,
    use: 'node-loader',
  },

  // Ignore WebAssembly if not needed
  {
    test: /\.wasm$/,
    type: 'javascript/auto',
    loader: 'ignore-loader',
  },

  // Ignore TypeScript definition files
  {
    test: /\.d\.ts$/,
    loader: 'ignore-loader',
  },
]);

env.plugins.append(
  'DefinePlugin',
  new webpack.DefinePlugin({
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
  })
);

env.config.set('optimization.minimizer', []);

env.config.set('ignoreWarnings', [
  {
    message: /the request of a dependency is an expression/,
  },
]);

module.exports = generateWebpackConfig(env.config);