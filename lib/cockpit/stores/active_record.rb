begin
  require "active_record"
rescue LoadError
  abort "You need the activerecord gem in order to use the ActiveRecord cockpit store"
end

module Cockpit
  module AR
    module Support
      def self.included(base)
        base.class_eval do
          has_many :settings, :as => :configurable, :class_name => "::Cockpit::AR::Setting", :dependent => :destroy
          
          unless respond_to?("get")
            def get(key)
              cockpit[key]
            end
          end
          
          unless respond_to?("set")
            def set(key, value)
              cockpit[key] = value
            end
          end
        end
      end
    end
    
    class Setting < ::ActiveRecord::Base
      set_table_name 'settings'
      belongs_to :configurable, :polymorphic => true
      
      def cockpit
        configurable ? configurable.cockpit : Cockpit::Settings.global
      end
      
      def parsed_value
        JSON.parse(value)['root']
      end
    end
    
    class Store
      attr_reader :record, :cache, :context
      
      def initialize(record, context = "default")
        @record = record
        @context = context
      end
      
      def key?(key)
        !!self[key]
      end
      
      def has_key?(key)
        key?(key)
      end
      
      def [](key)
        setting = find_setting(key)
        setting ? setting.parsed_value : nil
      end
    
      def []=(key, value)
        record.save! if record && record.new_record?
        
        setting = find_setting(key)
        attributes = {:value => {'root' => value}.to_json}#.merge(configurable_attributes)
        
        if setting
          setting.update_attributes!(attributes)
        else
          setting = Setting.new(attributes)
          setting.key = key
          record.settings << setting if record
          setting.save!
          cache << setting
        end
      end
      
      def delete(key)
        setting = find_setting(key)
        if setting
          setting.destroy
          setting.parsed_value
          record.reload if record
        end
      end
      
      def clear
        record.settings.destroy_all
      end
      
      def update_setting(setting)
        cache.map! do |item|
          item.id == setting.id ? setting : item
        end if cache
      end
      
      def cache
        if record
          @cache ||= record.settings.all
        else
          @cache ||= Setting.all(:conditions => configurable_attributes)
        end
        
        @cache
      end
      
      private
      def find_setting(key)
        cache.detect { |i| i.key == key }
      end
      
      def configurable_attributes
        conditions = {}
        if record
          conditions[:configurable_type] = [record.class.name, record.class.base_class.name]
          conditions[:configurable_id] = record.id
        else
          conditions[:configurable_type] = nil
          conditions[:configurable_id] = nil
        end
        conditions[:context] = context
        conditions
      end
    end
  end
end