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

        @cockpit.roots.map(&:key).flatten.each do |key|
          define_method key do
            send(:cockpit).send(key)
          end
          
          define_method "#{key}?" do
            send(:cockpit).has_key?(key)
          end
        end
      end
      
      @cockpit
    end
    
    unless respond_to?(:key)
      def key(*args)
        
      end
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
