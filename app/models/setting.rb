class Setting < ActiveRecord::Base
  acts_as_settable
  
  # set_table_name 'settings'
  # attr_protected :is_proc, :interpolations
  
  # serialize :value
  # serialize :interpolations, Array
  
  def save_with_setting
    if save_without_setting
       # update hash, eventually, just in case
    end
  end
  alias_method_chain :save, :setting
  
  class << self
    # adjust the arguments, so we find automatically by key
    def find(*args)
      key     = args.first
      unless key.to_s =~ /^(all|first|last)$/
        args[0] = :first
        options = args.extract_options!
        options[:conditions] = {:key => key.to_s} if key
        args << options
      end
      result = super(*args)
      # sync the global hash if necessary
      sync_settings_hash(result)
      
      result
    end
    
    def scoped(options = {}, &block)
      result = super(options, &block)
      sync_settings_hash(result)
      result
    end
    
    def sync_settings_hash(result)
      return unless result
      if result.is_a?(Array) || (defined?(ActiveRecord::Relation) && result.is_a?(ActiveRecord::Relation))
        result.each do |record|
          sync_setting(record)
        end
      else
        sync_setting(result)
      end
    end
    
    def sync_setting(record)
      record.value = Cockpit.type_cast(record.value, record.cast_as)
      if record.respond_to?(:key) && record.configurable.nil?
        Settings.store.set_one_without_database(record.key, record.value)
      end
    end
  end
  
end
