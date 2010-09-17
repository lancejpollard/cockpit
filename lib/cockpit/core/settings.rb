module Cockpit
  # settings have one direct definition and many child proxy
  class Settings
    class << self
      attr_accessor :definitions
      
      # Cockpit::Settings.define!(:name => "root", :scope => "default")
      def define!(*args, &block)
        setting = Cockpit::Settings.new(*args, &block)
        @root ||= setting
        setting
      end
      
      def store
        root.store
      end
      
      def store_type
        @store_type ||= :memory
      end
      
      def definitions
        @definitions ||= []
      end
      
      def definitions_for(name)
        definitions.detect do |i|
          i.name == name.to_s
        end
      end
      
      def definitions_for?(name)
        !definitions_for(name).blank?
      end
      
      def root
        @root ||= Cockpit::Settings.new(:name => "root", :store => store_type, :scope => "default")
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
      
      def inspect
        "Cockpit::Settings root: #{root.inspect}"
      end
    end
    
    attr_accessor :name, :scope, :store, :record

    # Settings.new(:store => :memory, :record => @user, :definitions => Settings.definitions.first)
    def initialize(*args, &block)
      options = args.extract_options!
      options[:name] ||= "root"
      options[:store] ||= args.first
      options.each do |k, v|
        send("#{k}=", v)
      end
      raise ArgumentError.new("pass in a :store to Cockpit::Settings") if self.store.nil?
      
      args << options
      
      if definition = self.class.definitions_for(options[:name])
        definition.define!(*args, &block)
      else
        self.class.definitions << Cockpit::Definitions.new(*args, &block)
      end
    end
    
    def store=(value)
      @store = Cockpit::Store.new(name, value, record).adapter
    end
    
    def merge!(hash)
      hash.each do |key, value|
        self[key] = value
      end
    end

    def keys
      definitions.keys
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
      !_definition(key).blank?
    end
    
    def default(key)
      _definition(key).value
    end
    
    def definition(key)
      _definition(key).dup
    end
    
    def to_hash
      keys.inject({}) do |hash, key|
        hash[key] = self[key]
        hash
      end
    end
    
    def roots
      @roots ||= keys.select { |key| key !~ /\./ }
    end
    
    protected
    def definitions
      @definitions ||= self.class.definitions_for(self.name)
    end
    
    def _definition(key)
      definitions[key.to_s]
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
