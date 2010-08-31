module Cockpit
  # This class defines default properties for a setting object, based on the DSL
  class Definition
    # keys is the nested keys associated with child values
    attr_accessor :key, :value, :keys, :nested, :parent, :attributes
    
    def initialize(key, *args, &block)
      process(key, *args, &block)
    end
    
    def process(key, *args, &block)
      self.key = key.to_s
      if args.length >= 1
        if args.last.is_a?(Hash)
          self.attributes = args.pop
        else
          self.attributes = {}
        end
      else
        self.attributes ||= {}
      end
      if block_given?
        self.value ||= []
        self.nested = true
        instance_eval(&block)
      else
        self.value = *args.first
        self.nested = false
      end
    end
    
    def [](key)
      if attributes.has_key?(key.to_sym)
        attributes[key.to_sym]
      elsif attributes.has_key?(key.to_s)
        attributes[key.to_s]
      else
        method_missing(key)
      end
    end
    
    def nested?
      self.nested == true
    end
    
    def keys(separator = ".")
      if nested?
        value.inject({key => self}) do |hash, definition|
          sub_definition = definition.keys.keys.inject({}) do |sub_hash, sub_key|
            sub_hash["#{key}#{separator}#{sub_key}"] = definition.keys[sub_key]
            sub_hash
          end
          hash.merge(sub_definition)
        end
      else
        {key => self}
      end
    end
    
    def method_missing(method, *args, &block)
      method  = method.to_s.gsub("=", "").to_sym
      if args.blank? && !block_given?
        result = self.value.detect do |definition|
          definition.key == method.to_s
        end
        result ? result.value : nil
      else
        old_value = self.value.detect { |definition| definition.key == method.to_s }
        if old_value
          old_value.process(method, *args, &block)
        else
          self.value << Cockpit::Definition.new(method, *args, &block)
        end
      end
    end
    
    class << self
      # top-level declaration are the first keys in the chain
      def define!(*args, &block)
        @definitions = []
        instance_eval(&block) if block_given?
        definitions = @definitions
        @definitions = nil
        definitions
      end
      
      def method_missing(method, *args, &block)
        method  = method.to_s.gsub("=", "").to_sym
        @definitions << Cockpit::Definition.new(method, *args, &block)
      end
    end
  end
end
