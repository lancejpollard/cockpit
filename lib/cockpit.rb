require 'rubygems'
require 'active_support'
require 'active_record'

this = File.expand_path(File.dirname(__FILE__))
Dir["#{this}/cockpit/*"].each { |c| require c }

class Settings
  include Cockpit::Configuration
end

ActiveRecord::Base.send(:include, Cockpit) if defined?(ActiveRecord::Base)

def Settings(*args, &block)
  Settings.define!(*args, &block)
end

def Cockpit(*args, &block)
  Settings(*args, &block)
end

require File.expand_path("#{this}/../app/models/setting.rb")
