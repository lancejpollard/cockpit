module Cockpit
  def self.included(base)
    base.send(:include, ObjectInclude)
    if defined?(::ActiveRecord::Base) && base.ancestors.include?(::ActiveRecord::Base)
      base.send(:include, ActiveRecordInclude)
    end
  end
  
  module ActiveRecordInclude
    def self.included(base)
      base.class_eval do
        def self.cockpit(*args, &block)
          if block_given?
            @cockpit = Cockpit::Settings.new(
              :name => self.name.underscore.gsub(/[^a-z0-9]/, "_").squeeze("_"),
              :scope => "default",
              :store => :active_record,
              &block
            )
          else
            @cockpit
          end
        end
        
        def cockpit
          unless @cockpit
            @cockpit = Cockpit::Settings.new(
              :name => self.class.cockpit.name,
              :scope => "default",
              :store => :active_record,
              :record => self
            )
          end
          
          @cockpit
        end
      end
    end
  end
  
  module ObjectInclude
    def self.included(base)
      base.class_eval do
        def self.cockpit(*args, &block)
          if block_given?
            @cockpit = Cockpit::Settings.new(
              :name => self.name.underscore.gsub(/[^a-z0-9]/, "_").squeeze("_"),
              :scope => "default",
              :store => args.first || "memory",
              &block
            )
          else
            @cockpit
          end
        end
        
        def cockpit
          unless @cockpit
            @cockpit = self.class.cockpit.dup
          end

          @cockpit
        end 
      end
    end
  end
end
