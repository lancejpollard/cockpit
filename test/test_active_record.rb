require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordTest < ActiveSupport::TestCase
  
  context "ActiveRecord" do
    
    setup do
      @user = User.new
    end

    should "have settings" do
      assert @user.cockpit
      assert_equal "default", @user.cockpit.name
      assert_equal :active_record, @user.cockpit.store_type
      assert_equal @user, @user.cockpit.record
    end
    
    should "get default settings" do
      assert_default_setting "Lance", String, @user.cockpit["implicitly_typed.string"]
      assert_default_setting %w(red green blue), Array, @user.cockpit["implicitly_typed.array"]
      assert_default_setting 1, Fixnum, @user.cockpit["implicitly_typed.integer"]
      assert_default_setting 1.0, Float, @user.cockpit["implicitly_typed.float"]
      assert_default_setting Time.parse("01-01-2001"), Time, @user.cockpit["implicitly_typed.datetime"]
    end
    
    should "set instance settings" do
      @user.cockpit["implicitly_typed.string"] = "Pollard"
      
      assert_equal "Pollard", @user.cockpit["implicitly_typed.string"]
      assert_equal "Pollard", Cockpit::ActiveRecord::Setting.find_by_key("implicitly_typed.string").parsed_value
    end
    
    should "get and set definitions dynamically via Cockpit::Scope" do
      assert_equal 1.0, @user.cockpit.implicitly_typed.float.value
      
      @user.cockpit.implicitly_typed.float.value = 2.0
      
      assert_equal 2.0, @user.cockpit.implicitly_typed.float.value
      assert_equal 2.0, Cockpit::ActiveRecord::Setting.find_by_key("implicitly_typed.float").parsed_value
    end
    
    should "be able to have custom attributes" do
      assert_kind_of Cockpit::Settings::Definition, @user.cockpit("with_attributes.array")
      assert_equal "Colors", @user.cockpit("with_attributes.array").attributes[:title]
    end

    context "global settings" do
      setup do
        @settings = load_settings
      end
      
      should "define global settings" do
        assert @settings
        assert_equal 100, @settings["asset.thumb.width"]
        assert_equal true, @settings["authentication.use_open_id"]
        assert_equal 3, @settings["site.teasers.center"]
        
        assert_equal @settings, Cockpit::Settings.global
        
        assert_equal 100, Cockpit::Settings("asset.thumb.width")
      end
    end
    
  end
  
end
