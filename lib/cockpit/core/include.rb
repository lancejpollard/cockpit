module Cockpit
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
    def cockpit(options = {}, &block)
      if block_given?
        options = {:store => options.to_sym} unless options.is_a?(Hash)
        @cockpit = Cockpit::Settings.define!(options.merge(:for => self), &block)
      end
      
      @cockpit
    end
  end
  
  module InstanceMethods
    def cockpit(key = nil)
      @cockpit ||= Cockpit::Settings.new(:record => self)
      if key
        @cockpit.definition(key)
      else
        @cockpit
      end
    end
  end
end
