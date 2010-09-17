module Cockpit
  # settings have one direct definition and many child definitions
  class Definitions < Hash
    attr_accessor :name, :scope
    
    def initialize(*args, &block)
      define!(*args, &block)
    end
    
    def define!(*args, &block)
      options = args.extract_options!
      options[:store] ||= args.first
      options.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
      raise ArgumentError.new("pass a :name to Cockpit::Setting.define!") if self.name.blank?
      if block_given?
        self << Cockpit::Definition.define!(&block)
      end
      self
    end
    
    def <<(value)
      ([value] + self.values).flatten.uniq.each do |definition|
        self.merge!(definition.keys)
      end
      self
    end
    
    def []=(key, value)
      self << Cockpit::Definition.new(key, value) unless has_key?(key)
      super(key.to_s, value)
    end
    
    def [](key)
      super(key.to_s)
    end
    
    def to_hash
      keys.inject({}) do |hash, key|
        hash[key] = self[key].value
        hash
      end
    end
    
    def method_missing(method, *args, &block)
      if has_key?(method)
        self[method]
      else
        super(method, *args, &block)
      end
    end
    
  end
end
