#!/usr/bin/env ruby

require './options'
require './app'

rtlamr_app_options = RTLAMRHomebusAppOptions.new

rtlamr = RTLAMRHomebusApp.new rtlamr_app_options.options
rtlamr.run!
