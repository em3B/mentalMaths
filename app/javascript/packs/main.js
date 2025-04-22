// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// app/javascript/packs/main.js
import 'bootstrap';
import "@hotwired/turbo-rails";
import '@babel/polyfill';
import Rails from "@rails/ujs";
import('./topic12_with_timer');
import('./topic12_without_timer');

Rails.start();
