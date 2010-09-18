module Cockpit
  class Settings
    # settings have one direct definition and many child definitions
    class Spec
      attr_reader :name, :roots # for "User"
    
      def initialize(options = {}, &block)
        @name     = options[:name]
        @store    = options[:store]
        @roots    = Cockpit::Settings::Definition.define!(options, &block)
      end
      
      # only returns keys that aren't defining a new scope.
      # so site { title "Hello"; pages 10 } would just return
      # ["site.title", "site.pages"], excluding "site"
      def keys
        @keys ||= roots.map(&:keys).flatten
      end
      
      # returns all keys, even the ones defining new scope
      def all_keys
        @all_keys ||= roots.map(&:all_keys).flatten
      end
      
      def has_key?(key)
        all_keys.include?(key.to_s)
      end
      
      def each(&block)
        roots.each { |root| root.each(&block) }
      end
      
      def map(&block)
        roots.map { |root| root.map(&block) }
      end
      alias_method :collect, :map
      
      def [](key)
        definition(key).value rescue nil
      end
      
      def definition(key)
        key = key.to_s
        return nil if key.empty?
        roots.each do |root|
          value = root.child(key)
          return value unless value.nil?
        end
        raise ArgumentError.new("Settings '#{name}' doesn't have key '#{key}'")
      end
      
      def to_hash
        keys.inject({}) do |hash, key|
          hash[key] = self[key]
          hash
        end
      end
      
      def to_tree
        roots.map(&:to_tree)
      end
      
    end
  end
end