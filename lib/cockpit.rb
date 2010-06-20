require 'rubygems'
require 'active_support'
require 'active_record'

this = File.dirname(__FILE__)
Dir["#{this}/cockpit/*"].each { |c| require c }

class Settings
  include Cockpit::Configuration
end

def Settings(*args, &block)
  Settings.configure(*args, &block)
end

def Cockpit(*args, &block)
  Settings(*args, &block)
end

ActiveRecord::Base.send(:include, Cockpit) if defined?(ActiveRecord::Base)

require "#{this}/../app/models/setting.rb"
