module Cockpit
  class Scope
    attr_reader :key, :settings
    
    def initialize(settings, method, *args, &block)
      @settings = settings
      process(method, *args, &block)
    end
    
    def value
      settings[key]
    end
    
    def value=(x)
      settings[key] = x
    end
    
    def process(method, *args, &block)
      node = method.to_s

      boolean = !!(node =~ /\?$/)
      node.gsub!(/\?/, "") if boolean
      
      set     = !!(node =~ /=$/)
      node.gsub!("=", "") if set
      
      if key
        @key       = "#{key}.#{node}"
      else
        @key       = node
      end
      
      if boolean == true
        settings.has_key?(key)
      elsif set == true
        self.value = args.pop
      else
        self
      end
    end
    
    def method_missing(method, *args, &block)
      process(method, *args, &block)
    end
  end
end
