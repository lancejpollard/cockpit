module Cockpit
  class Store
    class << self
      attr_accessor :stores
      
      def stores
        @stores ||= {}
      end
      
      def adapter(store)
        stores[store.name.to_s] ||= {}
        unless stores[store.name.to_s].has_key?(store.value.to_s)
          require 'moneta'
          stores[store.name.to_s][store.value.to_s] = case store.value.to_s
            when "mongo", "mongodb"
              require 'moneta/adapters/mongodb'
              Moneta::Adapters::MongoDB.new(:collection => store.name)
            when "active_record"
              require File.dirname(__FILE__) + '/../moneta/active_record'
              Moneta::Adapters::ActiveRecord.new
            when "file"
              require 'moneta/adapters/basic_file'
              Moneta::Adapters::BasicFile.new(:path => "./.cockpit")
            when "redis"
              require 'moneta/adapters/redis'
              Moneta::Adapters::Redis.new
            when "memory"
              require 'moneta/adapters/memory'
              Moneta::Adapters::Memory.new
            when "yaml"
              require 'moneta/adapters/yaml'
              Moneta::Adapters::YAML.new
            end
        end
        stores[store.name.to_s][store.value.to_s]
      end
    end
    
    attr_reader :name, :value
    
    def initialize(name, value)
      @name = name
      @value = value
    end
    
    def adapter
      self.class.adapter(self)
    end
  end
end
