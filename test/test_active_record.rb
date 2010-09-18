require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordTest < ActiveRecord::TestCase
  
  context "ActiveRecord" do
    
    context "settings on an instance" do
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
        
        record = Cockpit::ActiveRecord::Setting.find_by_key("implicitly_typed.float")

        assert_equal 2.0, @user.cockpit.implicitly_typed.float.value
        assert_equal 2.0, record.parsed_value
        assert_equal @user, record.configurable
      end

      should "be able to have custom attributes" do
        assert_kind_of Cockpit::Settings::Definition, @user.cockpit("with_attributes.array")
        assert_equal "Colors", @user.cockpit("with_attributes.array").attributes[:title]
      end
      
      should "only make one query to get settings" do
        @user.save!
        
        # ideally want some sort of caching mechanism, so it retrieves and saves all settings
        assert_queries(2) do
          user = User.last
          user.cockpit["with_attributes.array"]
          user.cockpit["implicitly_typed.float"]
        end
      end
      
      should "update cache when settings are created/updated" do
        @user = User.last
        
        assert_equal 1, @user.settings.all.length
        
        assert_equal @user.settings.all[0], @user.cockpit.store.cache[0]
        
        @user.cockpit["implicitly_typed.integer"] = 2
        
        assert_equal @user.settings.all[1], @user.cockpit.store.cache[1]

        assert_equal 2, @user.settings.all.length
      end
      
      should "distinguish between multiple instances" do
        user_a = User.create!
        user_b = User.create!
        
        user_a.cockpit["implicitly_typed.integer"] = 2
        user_b.cockpit["implicitly_typed.integer"] = 10
        
        user_a.reload
        user_b.reload
        
        assert_equal 1, User.cockpit["implicitly_typed.integer"]
        assert_equal 2, user_a.cockpit["implicitly_typed.integer"]
        assert_equal 10, user_b.cockpit["implicitly_typed.integer"]
      end
    end
    
    context "global settings" do
      setup do
        @settings = load_settings(:active_record)
      end
      
      should "get global settings" do
        assert @settings
        assert_equal 100, @settings["asset.thumb.width"]
        assert_equal true, @settings["authentication.use_open_id"]
        assert_equal 3, @settings["site.teasers.center"]
        
        assert_equal @settings, Cockpit::Settings.global
        
        assert_equal 100, Cockpit::Settings("asset.thumb.width")
        
        # Cockpit::Settings() references a method in global.rb, which calls method missing on Cockpit::Settings.global
        assert_equal true, Cockpit::Settings().asset?
        # Cockpit::Settings references the class, which calls method missing on Cockpit::Settings.global
        assert_equal true, Cockpit::Settings.asset.thumb?
        assert_equal true, Cockpit::Settings.asset.thumb.width?
      end
      
      should "set global settings" do
        Cockpit::Settings("asset.thumb.width", 200)
        
        record = Cockpit::ActiveRecord::Setting.find_by_key("asset.thumb.width")
        
        assert_equal 200, Cockpit::Settings("asset.thumb.width")
        assert_equal 200, record.parsed_value
        assert_equal nil, record.configurable
        
        Cockpit::Settings.page.per_page = 100
        
        assert_equal 100, Cockpit::Settings("page.per_page")
      end
    end
    
  end
  
end
