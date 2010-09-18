module Cockpit
  module Memory
    module Support
      
    end
    
    class Store < Hash
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
    end
  end
end
