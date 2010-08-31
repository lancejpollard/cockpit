module Cockpit
  def self.included(base)
    base.class_eval do
      def self.cockpit(*args, &block)
        if block_given?
          @cockpit = Cockpit::Settings.new(
            :name => self.name.underscore.gsub(/[^a-z0-9]/, "_").squeeze("_"),
            :scope => "default",
            :store => args.first || "memory",
            &block
          )
        else
          @cockpit
        end
      end
      
      def cockpit
        self.class.cockpit
      end
    end
  end
end
