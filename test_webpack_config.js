const { environment } = require('./config/webpack/environment');

console.log('Fallback config:', environment.config.get('resolve.fallback'));