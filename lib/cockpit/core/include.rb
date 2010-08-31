module Cockpit
  def self.included(base)
    base.class_eval do
      def self.cockpit(key = nil, &block)
        if block_given?
          @cockpit = Cockpit::Settings.new(self.name.underscore.gsub(/[^a-z0-9]/, "_").squeeze("_"), "default", &block)
        else
          if key
            @cockpit[key]
          else
            @cockpit
          end
        end
      end

      def cockpit(key = nil)
        self.class.cockpit(key)
      end
    end
  end
end
