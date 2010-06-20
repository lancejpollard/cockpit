module Cockpit
  module Store
    class Base
      attr_accessor :configurable
      
      def initialize(*args)
        options = args.extract_options!
        options.each do |k, v|
          self.send("#{k.to_s}=", v) if self.respond_to?("#{k.to_s}=")
        end
        @configuration = args.first
      end
      
      def configuration
        @configuration
      end
      
      def tree=(value)
        @tree = value if value.is_a?(TreeHash)
        @tree
      end
      
      def tree
        @tree ||= TreeHash.new
      end
      
      def clear(options = {})
        tree.each do |k, v|
          tree.delete(k) unless (options[:except] && options[:except].include?(k.to_sym))
        end
      end
      
      def get(path)
        tree.get(path)
      end
      alias_method :[], :get
      
      def get!(path)
        result = get(path)
        raise "'#{path.to_s}' was not in Config" if result.blank?
        result
      end
      
      def set(value)
        return unless value.is_a?(Hash)
        value.each { |k,v| set_one(k, v) }
      end
      
      def set_one(key, value)
        tree.set(key, value)
      end
      
      def set!(value)
        result = set(value)
        raise "'#{path.to_s}' was not set in Config" if result.blank?
        result
      end
      
      def []=(key, value)
        set_one(key => value)
      end
    end
    
    class Memory < Base
      
    end
    
    class Database < Base
      
      def clear(options = {})
        configuration.setting_class.all.collect(&:destroy) if options[:hard] == true
        super(options)
      end
      
      def find_or_create(key)
        result = configuration.setting_class.find(key.to_s) rescue nil
        result ||= configuration.setting_class.create(:key => key.to_s)
      end
      
      def set_one_with_database(key, value)
        setting = find_or_create(key)
        cast_as = (setting.cast_as || Cockpit.get_type(value)).to_s
        attributes = {:value => value, :cast_as => cast_as}
        attributes[:configurable] = self.configurable if self.configurable
        setting.update_attributes(attributes)
        set_one_without_database(key, Cockpit.type_cast(value, cast_as))
      end
      alias_method_chain :set_one, :database
      
      def get(key)
        result = super(key)
        if result.blank? && setting = find_or_create(key)
          set(key => setting.value)
          result = super(key)
        else
          
        end
        result
      end
      
    end
  end
end
