module Cockpit
  class Store
    class << self
      attr_accessor :stores
      
      def find(name)
        return store(name) if store?(name)
        
        base_path =  "#{File.dirname(__FILE__)}/../stores"
        
        @stores[name.to_sym] = case name.to_sym
        when :active_record
          require "#{base_path}/active_record"
          "::Cockpit::ActiveRecord"
        when :mongo
          require "#{base_path}/mongo"
          "::Cockpit::Mongo"
        else
          require "#{base_path}/memory"
          "::Cockpit::Memory"
        end
        
        store(name)
      end
      
      def use(options)
        eval("::#{find(options[:store])}::Store".gsub(/::[:]+/, "::")).new(options[:record], options[:name])
      end
      
      def support(name)
        eval("::#{find(name)}::Support".gsub(/::[:]+/, "::"))
      end
      
      def stores
        @stores ||= {}
      end
      
      def store(name)
        stores[name.to_sym]
      end
      
      def store?(name)
        stores.has_key?(name.to_sym)
      end
    end
  end
end
