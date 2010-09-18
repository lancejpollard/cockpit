begin
  require "mongoid"
rescue LoadError
  abort "You need the mongoid gem in order to use the ActiveRecord cockpit store"
end

module Cockpit
  module Mongo
    class Support
      def included(base)
        base.class_eval do
          embeds_many :settings, :as => :configurable
        end
      end
    end
    
    class Setting
      include Mongoid::Document
      field :key
      field :value
      field :context
      embedded_in :configurable, :inverse_of => :setting
    end
    
    class Store
      
    end
  end
end
