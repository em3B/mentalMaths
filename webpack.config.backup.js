const path = require("path");
const NodePolyfillPlugin = require('node-polyfill-webpack-plugin');

module.exports = {
  mode: "production",
  entry: {
    main: "./app/javascript/packs/main.js", // Define entry as an object with a named entry point
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.js$/, // transpile .js files with Babel
        use: 'babel-loader',
        exclude: /node_modules/,
      },
      // other rules can go here for handling CSS, images, etc.
    ],
  },
  plugins: [
    new NodePolyfillPlugin(), // Use the polyfill plugin to handle Node modules like fs, net, etc.
  ],
};
