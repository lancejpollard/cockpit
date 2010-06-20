require File.join(File.dirname(__FILE__), 'test_helper')

class SettingsTest < ActiveSupport::TestCase
  
  context "Settings" do
    context "acts_as_configurable module" do
      
      setup do
        @user = User.new
      end
      
      should "have added settings to global hash" do
        assert User.settings
        assert_equal "Lance", @user.settings.name.value
        assert_equal({:type => :string, :value => "red"}, @user.settings.favorite.color)
      end
      
      should "be able to set value" do
        Settings.user.login = "LOGIN"
        assert_equal({:type=>:string, :value => "LOGIN"}, Settings.user.login)
        assert_equal "LOGIN", Settings.user.login.value
      end
      
      context "multiple users, custom settings" do
        
        setup do
          Settings.clear(:except => [:user])
          @user_a = User.create
          @user_b = User.create
          @now    = Time.now
        end
        
        should "be able to change settings for user instances" do
          @user_a.settings[:im_a] = "yes"
          @user_b.settings[:im_b] = "yippee"
          assert_equal "yes", @user_a.settings(:im_a).value
          assert_equal "yippee", @user_b.settings.im_b.value
          assert_not_equal @user_a.settings, Settings(:user)
          assert_not_equal "yes", Settings(:user).im_a.value # global settings not changed
        end
        
        should "be able to save the user" do
          @user_a.settings.store = :db
          @user_a.settings["im_a.having.fun"] = "lance"
          @user_a.settings["im_a.having.a.good.time"] = @now
          assert @user_a.valid?
          assert_equal "lance", Setting.find_by_key("im_a.having.fun").value
          assert_equal @user_a, Setting.find_by_key("im_a.having.fun").configurable
          assert_equal @user_a, Setting.find_by_key("im_a.having.a.good.time").configurable
          assert_equal @now.to_s, Setting.find_by_key("im_a.having.a.good.time").value.to_s
          # global settings should be unchanged
          assert_kind_of Cockpit::Store::Database, @user_a.settings.store
          #assert_kind_of Cockpit::Store::Memory, Settings.store
        end
        
        teardown do
          @user_a.settings.store = :memory
        end
        
      end
      
    end
    
    teardown { Settings.clear(:except => [:user]) }
    
  end
  
end