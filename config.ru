#!/usr/bin/env ruby
require 'bundler'

Bundler.require

require './app'
run Sinatra::Application
