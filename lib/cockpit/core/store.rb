module Cockpit
  class Store
    class << self
      attr_accessor :stores
      
      def stores
        @stores ||= {}
      end
      
      def adapter(store)
        stores[store.name.to_s] ||= {}
#        unless stores[store.name.to_s].has_key?(store.value.to_s)
          require 'moneta'
          stores[store.name.to_s][store.value.to_s] = case store.value.to_s
            when "mongo", "mongodb"
              require 'moneta/mongodb'
              Moneta::MongoDB.new(:collection => store.name)
            when "active_record"
              require File.dirname(__FILE__) + '/../moneta/active_record'
              Moneta::ActiveRecord.new(:record => store.scope)
            when "file"
              require 'moneta/basic_file'
              Moneta::BasicFile.new(:path => "./.cockpit")
            when "redis"
              require 'moneta/redis'
              Moneta::Redis.new
            when "memory"
              require 'moneta/memory'
              Moneta::Memory.new
            when "yaml"
              require 'moneta/yaml'
              Moneta::YAML.new
            end
#        end
        stores[store.name.to_s][store.value.to_s]
      end
    end
    
    attr_reader :name, :value, :scope
    
    def initialize(name, value, scope = nil)
      @name = name
      @value = value
      @scope = scope
    end
    
    def adapter
      self.class.adapter(self)
    end
  end
end
