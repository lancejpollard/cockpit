require File.join(File.dirname(__FILE__), 'test_helper')

class StoreTest < ActiveSupport::TestCase
  
  context "Store" do
    
    context "ActiveRecord" do
      setup do
        @settings = Cockpit "active_record" do
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

      should "get/set values" do
        assert_equal "My Site", @settings["site.title"]
        @settings["site.title"] = "Another Site"
        assert_equal 1, Moneta::Adapters::ActiveRecord::Store.count
        assert_equal "Another Site", @settings["site.title"]
      end
      
      should "have user settings" do
        assert_equal %w(red green blue), User.cockpit["favorite.colors"]
        assert_equal "Lance", User.cockpit["appelation"]
        puts User.cockpit.definition("appelation").inspect
      end
      
    end
    
    context "MongoDB" do
      setup do
        @settings = Cockpit "mongodb" do
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

      should "get/set values" do
        assert_equal "My Site", @settings["site.title"]
        @settings["site.title"] = "Another Site"
        assert_equal "Another Site", @settings["site.title"]
      end
    end
    
    context "File" do
      setup do
        @settings = Cockpit "file" do
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
      
      should "get/set values" do
        assert_equal "My Site", @settings["site.title"]
        @settings["site.title"] = "Another Site"
        assert_equal "Another Site", @settings["site.title"]
      end
    end
    
    context "Memory" do
      setup do
        @settings = Cockpit "memory" do
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
      
      should "get/set values" do
        assert_equal "My Site", @settings["site.title"]
        @settings["site.title"] = "Another Site"
        assert_equal "Another Site", @settings["site.title"]
      end
    end
    
    teardown do
      Cockpit::Settings.clear
    end
    
  end
  
end