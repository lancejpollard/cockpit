require 'rubygems'
require 'defined-by'

this = File.expand_path(File.dirname(__FILE__))
Dir["#{this}/cockpit/*"].each { |c| require c unless File.directory?(c) }
Dir["#{this}/cockpit/core/*"].each { |c| require c unless File.directory?(c) }
Dir["#{this}/cockpit/adapters/*"].each { |c| require c unless File.directory?(c) }

ActiveRecord::Base.send(:include, Cockpit) if defined?(ActiveRecord::Base)

def Settings(*args, &block)
  Cockpit::Settings.define!(*args, &block)
end

def Cockpit(*args, &block)
  Settings(*args, &block)
end

module Cockpit
  def self.version
    @version ||= IO.read(File.dirname(__FILE__) + '/../VERSION')
  end
end