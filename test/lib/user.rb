class User < ActiveRecord::Base
  acts_as_configurable :settings do
    name "Lance", :title => "First Name", :options => ["Lance", "Viatropos"]
    favorite do
      color "red"
    end
  end
end
