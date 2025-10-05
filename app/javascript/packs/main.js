// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'bootstrap';
import "@hotwired/turbo-rails";
import '@babel/polyfill';
import Rails from "@rails/ujs";
import {runTopic38WithoutTimer}from './topic38_without_timer';
import {runTopic38WithTimer} from './topic38_with_timer';
import {runTopic39WithoutTimer} from './topic39_without_timer';
import {runTopic39WithTimer} from './topic39_with_timer';
import {runTopic40WithoutTimer} from './topic40_without_timer';
import {runTopic40WithTimer} from './topic40_with_timer';
import {runTopic41WithoutTimer} from './topic41_without_timer';
import {runTopic41WithTimer} from './topic41_with_timer';

window.PRELOADED_GAMES = {
  38: { withTimer: runTopic38WithTimer, withoutTimer: runTopic38WithoutTimer },
  39: { withTimer: runTopic39WithTimer, withoutTimer: runTopic39WithoutTimer },
  40: { withTimer: runTopic40WithTimer, withoutTimer: runTopic40WithoutTimer},
  41: { withTimer: runTopic41WithTimer, withoutTimer: runTopic41WithoutTimer}
};

Rails.start();