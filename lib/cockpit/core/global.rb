module Cockpit
  class Settings
    module Global
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def [](key)
          global[key]
        end
        
        def []=(key, value)
          global[key] = value
        end
      end
    end
  end
  
  def self.Settings(*args)
    case args.length
    when 0
      nil
    when 1
      case args.first
      when Hash
        
      else
        Cockpit::Settings[args.first]
      end
    when 2
      Cockpit::Settings[args.first] = args.last
    end
  end
end
