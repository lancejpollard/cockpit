=begin
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
          if block_given? || @cockpit.nil?
            
            has_many :settings, :class_name => "Moneta::ActiveRecord::Setting", :dependent => :destroy
            
            @cockpit = Cockpit::Settings.new(
              :name => self.name.underscore.gsub(/[^a-z0-9]/, "_").squeeze("_"),
              :store => :active_record,
              &block
            )
            
            @cockpit.keys.each do |key|
              next if key =~ /\./
              
              define_method key do
                send(:cockpit)[key]
              end
              
              define_method "#{key}?" do
                !send(key).blank?
              end
            end
            
          else
            @cockpit
          end
        end
        
        def cockpit
          unless @cockpit
            @cockpit = Cockpit::Settings.new(
              :name => self.class.cockpit.name,
              :store => :active_record,
              :record => self
            )
          end
          
          @cockpit
        end
        
        def get(key)
          cockpit[key]
        end unless respond_to?(:get)

        def set(*args)
          if args.last.is_a?(Hash)
            cockpit.set(args.last)
          else
            cockpit[args.first] = args.last
          end
        end unless respond_to?(:set)
        
        def setting(key)
          cockpit[key]
        end
        
        def setting?(key)
          cockpit.has_key?(key)
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
=end