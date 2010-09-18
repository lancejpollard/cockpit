module Cockpit
  module ViewHelpers
    unless respond_to?(:c)
      def c(key)
        Cockpit::Settings.global[key]
      end
    end
  end
end

::ActionView::Helpers.send(:include, Cockpit::ViewHelpers) if defined?(::ActionView::Helpers)
::Sinatra.helpers.send(:helper, Cockpit::ViewHelpers) if defined?(::Sinatra)
