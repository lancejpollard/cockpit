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
      
      def keys
        roots.map(&:keys).flatten
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
        nil
      end
      
    end
  end
end