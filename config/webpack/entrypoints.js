const fs = require('fs');
const path = require('path');

const entrypoints = {
  application: './app/javascript/packs/main.js',
};

// Dynamically add topic entrypoints
const packsDir = path.resolve(__dirname, '../../app/javascript/packs');
const files = fs.readdirSync(packsDir);

files.forEach((file) => {
  if (/^topic\d+_(with|without)_timer\.js$/.test(file)) {
    const name = file.replace('.js', '');
    entrypoints[name] = `./app/javascript/packs/${file}`;
  }
});

module.exports = entrypoints;