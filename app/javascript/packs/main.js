// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'bootstrap';
import "@hotwired/turbo-rails";
import '@babel/polyfill';
import Rails from "@rails/ujs";

// Don't import topics here; they're loaded dynamically later

Rails.start();
