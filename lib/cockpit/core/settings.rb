module Cockpit
  # settings have one direct definition and many child proxy
  class Settings
    class << self
      def root
        @root ||= Cockpit::Settings.new(:name => "root", :scope => "default")
      end
      
      def define!(*args, &block)
        root.define!(*args, &block)
      end
      
      def proxy
        root.proxy
      end
      
      def definitions
        root.definitions
      end
      
      def keys
        root.keys
      end
      
      def store
        root.store
      end
      
      def merge!(hash)
        root.merge!(hash)
      end

      def [](key)
        root[key]
      end

      def []=(key, value)
        root[key] = value
      end

      def clear
        root.clear
      end

      def default(key)
        root.default(key)
      end
    end
    
    attr_accessor :name, :scope

    def initialize(options = {}, &block)
      options.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end
      raise "i need a name" unless self.name
      raise "Set the scope on the settings!" unless self.scope
      define!(&block)
    end
    
    def define!(*args, &block)
      proxy.define!(*args, &block)
      self
    end
        
    def proxy
      @proxy ||= Cockpit::Proxy.new(name, scope)
    end
    
    def definitions
      proxy.definitions
    end
    
    def definition(key)
      proxy.definition(key)
    end
    
    def keys
      proxy.keys
    end
    
    def store
      proxy.store
    end
    
    def store=(value)
      proxy.store = value
    end
    
    def [](key)
      proxy[key]
    end
    
    def []=(key, value)
      proxy[key] = value
    end
    
    def has_key?(key)
      proxy.has_key?(key)
    end
    
    def clear
      proxy.clear
    end
    
    def default(key)
      proxy.default(key)
    end
    
    def method_missing(method, *args, &block)
      proxy.method_missing(method, *args, &block)
    end
  end
end
