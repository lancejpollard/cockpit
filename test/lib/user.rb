class User < ActiveRecord::Base
  include Cockpit
  
  cockpit "mongo" do
    appelation "Lance", :title => "First Name", :options => ["Lance", "Viatropos"]
    favorite do
      colors %w(red green blue)
    end
  end
end
