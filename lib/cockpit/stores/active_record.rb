begin
  require "active_record"
rescue LoadError
  abort "You need the activerecord gem in order to use the ActiveRecord moneta store"
end

module Cockpit
  module ActiveRecord
    module Support
      def self.included(base)
        base.class_eval do
          has_many :settings, :as => :configurable, :class_name => "::Cockpit::ActiveRecord::Setting", :dependent => :destroy
          
          unless respond_to?("get")
            def get(key)
              cockpit[key]
            end
          end
          
          unless respond_to?("set=")
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
      
      def parsed_value
        JSON.parse(value)['root']
      end
    end
    
    class Store
      attr_reader :record
      
      def initialize(record)
        @record = record
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
        attributes = {:value => {'root' => value}.to_json}.merge(configurable_attributes)
        
        if setting
          setting.update_attributes!(attributes)
        else
          setting = Setting.new(attributes)
          setting.key = key
          setting.save!
          record.settings << setting if record
        end
      end
      
      def fetch(key, value = nil)
        value ||= block_given? ? yield(key) : default # TODO: Shouldn't yield if key is present?
        self[key] || value
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
      
      private
      def find_setting(key)
        if record
          return nil if record.new_record?
          record.settings.all.detect { |i| i.key == key }
        else
          Setting.find_by_key(key, :conditions => configurable_attributes)
        end
      end
      
      def configurable_attributes
        conditions = {}
        if record
          conditions[:configurable_type] = record.class.name
          conditions[:configurable_id] = record.id
        else
          conditions[:configurable_type] = nil
          conditions[:configurable_id] = nil
        end
        conditions
      end
    end
  end
end