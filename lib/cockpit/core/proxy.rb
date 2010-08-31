module Cockpit
  # settings have one direct definition and many child definitions
  class Proxy
    attr_accessor :name, :scope, :store, :definitions
    
    def define!(*args, &block)
      if block_given?
        if args.first
          @store = Cockpit::Store.new(name, args.first).adapter
        end
        self << Cockpit::Definition.define!(&block)
        self
      elsif args.first.is_a?(String)
        self[args.first]
      elsif args.first.is_a?(Hash)
        self.merge!(args.first)
        self
      end
    end
    
    def initialize(name, scope = "default")
      self.name = name
      self.scope = scope
    end
    
    def definitions
      @definitions ||= {}
    end
    
    def definition(key)
      definitions[key.to_s]
    end
    
    def <<(value)
      self.definitions = ([value] + self.definitions.values).flatten.uniq.inject(self.definitions) do |hash, definition|
        hash.merge(definition.keys)
      end
      self.definitions
    end
    
    def get(key)
      if has_key?(key)
        definition(key).value
      end
    end
    
    def set(key, value)
      self << Cockpit::Definition.new(key, value) unless has_key?(key)
      definition(key).value = value
    end
    
    def has_key?(key)
      !definition(key).blank?
    end
    
    def clear
      @definitions = nil
      @definitions      = nil
      nil
    end
    
    def store
      @store ||= Cockpit::Store.new(name, "memory").adapter
    end
    
    def merge!(hash)
      hash.each do |key, value|
        self[key] = value
        self.store["#{scope}.#{key.to_s}"] = value
      end
    end
    
    def keys
      definitions.keys
    end
    
    def [](key)
      self.store["#{scope}.#{key.to_s}"] || self.get(key)
    end
    
    def []=(key, value)
      self.store["#{scope}.#{key.to_s}"] = value
      self.set(key, value)
    end
    
    def clear
      self.store.clear
      @definitions  = nil
      nil
    end
    
    def default(key)
      definition(key).value
    end
    
    def method_missing(method, *args, &block)
      if has_key?(method)
        definition(method)
      else
        super(method, *args, &block)
      end
    end
    
  end
end
