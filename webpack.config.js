const path = require("path");

module.exports = {
  mode: "production",
  entry: {
    main: "./app/javascript/application.js"  // Define entry as an object with a named entry point
  },
  output: {
    filename: "[name].js",  // Use the entry point name in the output file
    path: path.resolve(__dirname, "public/packs"),
  },
  node: {
    fs: 'empty',  // Empty mock for fs
    net: 'empty', // Empty mock for net
    tls: 'empty', // Empty mock for tls
    dgram: 'empty', // Empty mock for dgram
    child_process: 'empty', // Empty mock for child_process
  },
  plugins: [],
};
