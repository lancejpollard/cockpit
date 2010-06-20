module Cockpit::Helper
  
  # always returns either an array or a string
  def c(*args)
    options = args.extract_options!
    result = args.collect {|i| Settings.get(i).value }
    result = result.pop if result.length == 1
    result.blank? ? nil : result.to_s
  end
  
  def setting_tag(tag)
    
  end
  
  def settings_tag(key, &block)
    Settings(key).each_setting do |key, attributes, value|
      
    end
  end
  
  def setting_value(value)
    result = case value
      when Proc
        value.call
      when Cockpit::TreeHash
        value
      else
        value
      end
  end
  
  def setting_options(attributes)
    return {} unless (attributes.is_a?(Hash) && attributes[:options])
    options = case attributes[:options]
      when Proc
        attributes[:options].call
      else
        attributes[:options]
      end
  end
  
end

ActionView::Base.send(:include, Cockpit::Helper) if defined?(ActionView)