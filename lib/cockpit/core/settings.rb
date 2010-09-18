module Cockpit
  # settings have one direct definition and many child proxy
  class Settings
    include Global
    
    class << self
      def specs
        @specs ||= {}
      end
      
      def define!(options = {}, &block)
        options = {:store => options.to_sym} unless options.is_a?(Hash)
        options = configure(options)
        
        unless options[:class] == NilClass
          options[:class].send(:include, Cockpit::Store.support(options[:store]))
        end
        
        spec options[:name], options[:class], Cockpit::Settings::Spec.new(options, &block)
        
        settings  = Cockpit::Settings.new(options)
        
        @global   = settings if options[:name] == "default" && options[:class] == NilClass
        
        settings
      end
      
      def configure(options)
        name                = (options[:name]  || "default").to_s
        relationship        = options[:class] || options[:for] || options[:class_name] || options[:record]
        store               = options[:store]
        
        # class to include this in
        clazz = case relationship
        when Class
          relationship
        when Object
          relationship.class
        when String, Symbol
          Object.const_get(relationship.to_s)
        else
          NilClass
        end
        
        # store to use in the include
        unless store
          if defined?(::ActiveRecord::Base) && clazz.ancestors.include?(::ActiveRecord::Base)
            store = :active_record
          else
            store = :memory
          end
        end
        
        options[:class] = clazz
        options[:store] = store
        options[:name]  = name
        
        options
      end
      
      def spec(name, clazz = NilClass, value = nil)
        specs[clazz.to_s] ||= {}
        specs[clazz.to_s][name.to_s] ||= value if value
        specs[clazz.to_s][name.to_s]
      end
      
      def global
        @global
      end
      
      def method_missing(method, *args, &block)
        global.send(method, *args, &block)
      end
    end
    
    attr_reader :name, :record, :store, :store_type, :record_type

    def initialize(options = {}, &block)
      options   = self.class.configure(options)
      @name     = options[:name]
      @record   = options[:record]
      @record_type = options[:class] || @record.class
      @store_type = options[:store]
      @store    = Cockpit::Store.use(options)
    end
    
    def merge!(hash)
      hash.each do |key, value|
        self[key] = value
      end
    end
    
    def keys
      spec.keys
    end
    
    def [](key)
      self.store[key.to_s] || default(key.to_s)
    end
    
    def []=(key, value)
      self.store[key.to_s] = value
    end
    
    def clear
      self.store.clear
    end
    
    def has_key?(key)
      spec.has_key?(key)#!definition(key).blank?
    end
    
    def default(key)
      definition(key).value
    end
    
    def definition(key)
      spec.definition(key)
    end
    
    def to_hash
      keys.inject({}) do |hash, key|
        hash[key] = self[key]
        hash
      end
    end
    
    def each(&block)
      keys.each do |key|
        case block.arity
        when 1
          yield(key)
        when 2
          yield(key, self[key])
        end
      end
    end
    
    def roots
      spec.roots
    end
    
    def spec
      @spec ||= self.class.spec(self.name, self.record_type)
    end
    
    protected
    
    def method_missing(method, *args, &block)
      if method.to_s =~ /(\w+)\?$/
        has_key?($1)
      elsif has_key?(method)
        Cockpit::Scope.new(self, method, *args, &block)
      else
        super(method, *args, &block)
      end
    end
  end
end
