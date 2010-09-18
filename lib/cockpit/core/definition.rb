module Cockpit
  class Settings
    # This class defines default properties for a setting object, based on the DSL
    class Definition
      
      class << self
        def define!(options = {}, &block)
          DefinedBy::DSL(&block).map do |key, value, dsl_block|
            Cockpit::Settings::Definition.new(key, value, &dsl_block)
          end
        end
      end
      
      # keys is the nested keys associated with child values
      attr_reader :key, :value
      attr_reader :attributes, :type
      attr_reader :nested
      
      def initialize(key, *args, &block)
        @key        = key.to_s
        @attributes = {}
        
        if block_given?
          @value    = self.class.define!(&block)
          @nested   = true
        else
          args = args.pop
          if args.is_a?(Array)
            if args.last.is_a?(Hash)
              @attributes.merge!(args.pop)
            end
            if args.last.is_a?(Class)
              @type = args.pop
            end
            
            args = args.pop if (args.length == 1)
          end
          
          if attributes.has_key?(:default)
            @value = attributes.delete(:default)
          else
            @value = args
          end
          
          @type     ||= @value.class
          @nested   = false
        end
      end
      
      def each(&block)
        iterate(:each, &block)
      end
      
      def map(&block)
        iterate(:map, &block)
      end
      
      def iterate(method, &block)
        keys.send(method) do |key|
          case block.arity
          when 1
            yield(key)
          when 2
            yield(key, value_for(key))
          end
        end
      end
      
      def keys
        @keys ||= get_keys(false, :keys)
      end
      
      def all_keys
        @all_keys ||= get_keys(true, :all_keys)
      end
      
      def child(key)
        flatten[key.to_s]
      end
      
      def value_for(key)
        child(key).value rescue nil
      end
      
      def [](key)
        value_for(key)
      end
      
      # map of nested key to definition
      def flatten(separator = ".")
        unless @flattened
          if nested?
            @flattened = value.inject({key => self}) do |hash, definition|
              sub_definition = definition.keys.inject({}) do |sub_hash, sub_key|
                sub_hash["#{key}#{separator}#{sub_key}"] = definition.child(sub_key)
                sub_hash
              end
              hash.merge(sub_definition)
            end
          else
            @flattened = {key => self}
          end
        end
        
        @flattened
      end
      
      def to_hash
        flatten.inject({}) do |hash, key, definition|
          hash[key] = definition.value unless definition.nested?
          hash
        end
      end
      
      def to_tree
        {key => nested? ? value.map(&:to_tree) : value}
      end
      
      def nested?
        self.nested == true
      end
      
      protected
      def get_keys(include_self, method)
        if nested?
          @keys = include_self ? [key] : []
          @keys += value.map(&method).flatten.map {|key| "#{self.key}.#{key}"}
        else
          @keys = [key]
        end
      end
    end
  end
end
