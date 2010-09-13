module Cockpit
  module Many
    class Settings
      class << self
        def define(&block)
          DefinedBy::DSL(&block).each do |key, value, dsl_block|
            
          end
        end
      end
    end
    
    class Setting
      attr_reader :definition
      
      def method_name
        
      end
    end
  end
end
