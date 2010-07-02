module Cockpit
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    # can be "unique_by_key"
    # settings :text do
    #   ...
    # settings :social do
    #   ...
    def acts_as_configurable(*args, &block)
      options = args.extract_options!
      settings_name = (args.shift || "settings").to_s
      clazz_name = self.to_s.downcase.split("::").last

      class_inheritable_accessor settings_name
      has_many settings_name, :class_name => "Setting", :as => :configurable
      
      Settings { send(clazz_name, &block) }
      
      self.send("#{settings_name}=", ::Settings.for(clazz_name))

      define_method settings_name do |*value|
        unless @settings
          @settings = self.class.send(settings_name).dup
          @settings.configurable = self
        end
        
        unless value.empty?
          @settings[value.first]
        else
          @settings
        end
        # model-dependent settings.
        # requires refactoring the Settings module
        # so none of it uses class methods...
      end
      
    end
    alias configurable acts_as_configurable
    alias settings acts_as_configurable
    
    def acts_as_settable
      belongs_to :configurable, :polymorphic => true
    end
  end
  
  def self.get_type(object)
    result = case object
      when Fixnum
        :integer
      when Array
        :array
      when Float # decimal
        :float
      when String
        :string
      when Proc
        :proc
      when TrueClass
        :boolean
      when FalseClass
        :boolean
      when DateTime
        :datetime
      when Time
        :time
      else
        :string
      end    
  end
  
  def self.type_cast(object, type)
    return object if type.nil?
    result = case type.to_sym
      when :integer
        object.to_i
      when :array
        object.to_a
      when :float, :decimal # decimal
        object.to_f
      when :string, :text
        object.to_s
      when :boolean
        if object == "true" || object == true || object == "1" || object == 1 || object == "t"
          true
        else
          false
        end
      when :datetime, :timestamp
        object.is_a?(String) ? DateTime.parse(object) : object
      when :time
        object.is_a?(String) ? Time.parse(object) : object
      else
        object.to_s
      end
  end
  
end