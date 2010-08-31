require File.join(File.dirname(__FILE__), 'test_helper')

class MongoDBTest < ActiveSupport::TestCase
  
  context "MongoDB" do
    
    setup do
      Cockpit "mongo" do
        site do
          title "My Site"
          time_zone lambda { "Hawaii" }
          feed do
            per_page 10
            formats %w(rss atom)
          end
        end
      end
    end
    
    should "retrieve default values" do
      assert_equal "My Site", Cockpit::Settings.default("site.title")
    end
    
    should "define default values at runtime" do
      Cockpit::Settings["site.title"] = "New Site"
      assert_equal "New Site", Cockpit::Settings.default("site.title")
      assert_equal "New Site", Cockpit::Settings["site.title"]
    end
    
    should "use moneta" do
      assert Cockpit::Settings.store
      Cockpit::Settings["site.title"] = "Another Site"
      assert_equal "Another Site", Cockpit::Settings.store["default.site.title"]
    end
    
    context "instance" do
      setup do
        @settings = Cockpit::Settings.new("site-cache", "default") do
          site "a site"
        end
      end
      
      should "have an instance of setting" do
        assert @settings
        assert_equal "a site", @settings["site"]
        class User
          cockpit do
            author "Lance"
            title do
              last_name "Pollard"
            end
          end
        end
        assert_equal "Lance", User.cockpit("author")
        assert_equal "Pollard", User.cockpit("title.last_name")
        
        user = User.new
        assert_equal "Lance", user.cockpit("author")
        assert_equal "Pollard", user.cockpit("title.last_name")
        
        settings = load_settings
      end
    end
    
    teardown do
      Cockpit::Settings.clear
    end
    
  end
  
end