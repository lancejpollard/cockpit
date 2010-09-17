begin
  require "active_record"
rescue LoadError
  puts "You need the activerecord gem in order to use the ActiveRecord moneta store"
  exit
end

module Moneta
  class ActiveRecord
    class Store < ::ActiveRecord::Base
      set_primary_key 'key'
      set_table_name 'settings'
      belongs_to :configurable, :polymorphic => true

      def parsed_value
        JSON.parse(value)['root']
      end
    end
    
    def initialize(options = {})
      @options = options
      @configurable = options[:record]
      @cache = []
      #Store.establish_connection(@options[:connection] || raise("Must specify :connection"))
      Store.set_table_name(@options[:table] || 'settings')
    end
    
    module Implementation
      def key?(key)
        !!self[key]
      end
      
      def has_key?(key)
        key?(key)
      end

      def [](key)
        record = find_record(key)
        record ? record.parsed_value : nil
      end
      
      def []=(key, value)
        record = find_record(key)
        attributes = {:value => {'root' => value}.to_json}.merge(configurable_attributes)
        if record
          record.update_attributes!(attributes)
        else
          store = Store.new(attributes)
          store.key = key
          store.save!
          @cache << store
        end
      end
      
      def fetch(key, value = nil)
        value ||= block_given? ? yield(key) : default # TODO: Shouldn't yield if key is present?
        self[key] || value
      end

      def delete(key)
        record = find_record(key)
        if record
          @cache.delete(record)
          record.destroy
          record.parsed_value
        end
      end
      
      def store(key, value, options = {})
        self[key] = value
      end

      def clear
        #Store.delete_all
      end
      
      private
      def find_record(key)
        if record = @cache.detect { |i| i.key == key }
          record
        else
          @cache = Store.all(:conditions => configurable_attributes)
          Store.find_by_key(key, :conditions => configurable_attributes) rescue nil
        end
      end
      
      def configurable_attributes
        conditions = {}
        if @configurable
          conditions[:configurable_type] = @configurable.class.name
          conditions[:configurable_id] = @configurable.id
        else
          conditions[:configurable_type] = nil
          conditions[:configurable_id] = nil
        end
        conditions
      end
      
    end
    
    # Unimplemented
    module Expiration
      def update_key(key, options)
      end
    end

    include Implementation
    include Expiration
  end
end