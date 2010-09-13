require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordTest < ActiveSupport::TestCase
  
  context "ActiveRecord" do
    
    setup do
      Cockpit :active_record do
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

    should "define values at runtime" do
      Cockpit::Settings["site.title"] = "New Site"
      assert_equal "New Site", Cockpit::Settings["site.title"]
    end

    should "use moneta" do
      assert Cockpit::Settings.store
      Cockpit::Settings["site.title"] = "Another Site"
      assert_equal "Another Site", Cockpit::Settings.store["site.title"]
    #  puts Moneta::Adapters::ActiveRecord::Store.all.inspect
    end
    
    context "instance" do
      setup do
        @settings = Cockpit::Settings.new(:store => :active_record, :name => "site-cache", :scope => "default") do
          site "a site"
        end
      end
      
      should "have an instance of setting" do
        assert @settings
        assert_equal "a site", @settings["site"]
        class User < ::ActiveRecord::Base
          cockpit :active_record do
            author "Lance"
            title do
              last_name "Pollard"
            end
          end
        end
        assert_equal "Lance", User.cockpit["author"]
        assert_equal "Pollard", User.cockpit["title.last_name"]
        
        user = User.new
        assert_equal "Lance", user.cockpit["author"]
        assert_equal "Pollard", user.cockpit["title.last_name"]
      end
      
      should "be able to assiociate Proc and hash" do
        require 'tzinfo'
        @settings = Cockpit :active_record do
          site do
            time_zones "MST", :options => Proc.new { TZInfo::Timezone.all.map(&:name) }
          end
        end
        
        assert_equal TZInfo::Timezone.all.map(&:name), @settings.definition("site.time_zones")[:options].call
      end
    end
    
    teardown do
      Cockpit::Settings.clear
    end
    
  end
  
end