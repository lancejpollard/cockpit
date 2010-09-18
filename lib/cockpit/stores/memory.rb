module Cockpit
  module Memory
    module Support
      
    end
    
    class Store < Hash
      attr_reader :name, :context
      
      def initialize(name, context = "default")
        @name = name
        @context = context
      end
    end
  end
end
