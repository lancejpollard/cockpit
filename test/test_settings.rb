require File.join(File.dirname(__FILE__), 'test_helper')

class SettingsTest < ActiveSupport::TestCase
  
  context "Settings" do
    
    setup do
      Settings.store = :memory
      Settings.set(:lance => "first", :dane => 2)
    end
    
    should "have have values" do
      desired_result = {
        :lance => {
          :type => :string,
          :value => "first"
        },
        :dane => {
          :type => :integer,
          :value => 2
        }
      }
      assert_equal(desired_result, Settings.tree)
    end
    
    context "get" do
      
      setup do
        Settings.clear
        Settings.set(:lance => "first", :dane => 2)
      end
      
      should "be able to get values" do
        assert_equal "first", Settings.get(:lance).value
        assert_equal :string, Settings.get(:lance).value_type
        assert_equal :integer, Settings.get(:dane).value_type
      end
      
      should "be able ot get values by using string" do
        assert_equal "first", Settings.get("lance").value
      end
      
      should "be able to get values using all syntax" do
        assert_equal "first", Settings.get("lance").value
        assert_equal "first", Settings("lance").value
        assert_equal "first", Settings["lance"].value
        assert_equal "first", Settings.lance.value
      end
      
      should "return empty TreeHash if value doesn't exist" do
        assert_equal({}, Settings.get("nope"))
        assert_equal false, Settings.get("nope").nil?
        assert Settings.get("nope").empty?
        assert Settings.get("nope").blank?
        assert_equal({}, Settings["asset.thumb.random"].value)
      end
      
      should "raise an error if we use exclamation on 'get!'" do
        assert_raise(RuntimeError) { Settings.get!("nope") }
      end
    end
    
    context "set" do
      
      setup do
        Settings.clear
      end
      
      should "be able to set new values" do
        Settings.set(:name => "value")
        assert_equal "value", Settings[:name].value
      end
      
      should "be able to set using []=" do
        Settings[:name] = "value"
        assert_equal "value", Settings[:name].value
      end
      
      should "not be able to set a value if it's a string" do
        assert_equal nil, Settings.set("set value")
      end
      
      should "be able to set a value using parentheses syntax" do
        Settings("path.to.hash" => "me")
        assert_equal "me", Settings("path.to.hash").value
      end
      
    end
    
    context "nested values" do
      
      should "be able to set nested value by string key" do
        Settings["a.nested.string"] = "value"
        assert_equal "value", Settings["a.nested.string"].value
        assert_kind_of Cockpit::TreeHash, Settings["a.nested"]
      end
      
      should "be able to change string to further nested hash" do
        Settings["a.nested.string"] = "value"
        assert_equal "value", Settings["a.nested.string"].value
        Settings["a.nested.string.with.further.depth"] = "value"
        assert_equal "value", Settings["a.nested.string.with.further.depth"].value
        Settings["a.nested.string"] = "value"
        assert_equal "value", Settings["a.nested.string"].value
      end
      
    end
    
    context "with dsl" do
      
      setup do
        Settings.clear
        Settings do
          asset :title => "Asset (and related) Settings" do
            thumb do
              width 100, :tip => "Thumb's width"
              height 100, :tip => "Thumb's height"
            end
          end
        end
      end
      
      should "property should be a hash of values" do
        desired_result = {
          :type => :integer,
          :value => 100,
          :tip => "Thumb's width"
        }
        assert_equal(desired_result, Settings["asset.thumb.width"])
      end
      
      should "be able to call 'value' on object" do
        assert_equal 100, Settings["asset.thumb.width.value"]
        assert_equal 100, Settings["asset.thumb.width"].value
      end
      
      should "be able to call 'tip' if it has tooltip" do
        assert_equal "Thumb's width", Settings["asset.thumb.width"].tip
      end
      
      should "be able to call 'tip' through chain" do
        assert_equal "Thumb's width", Settings.asset.thumb.width.tip
      end
      
      context "should be able to take a lambda as a value" do
        
        setup do
          Settings.clear
          @languages = %w(English Italian Spanish)
          Settings do
            site :title => "Default Site Settings" do
              languages :value => lambda { %w(English Italian Spanish) }
            end
          end
        end
        
        should "have a proc as a value" do
          assert_kind_of Proc, Settings["site.languages.value"]
        end
        
        should "be able to call the proc" do
          assert @languages, Settings["site.languages.value"].call
        end
                
      end
      
      context "should be able to take a Proc.new as a value" do
        setup do
          Settings.clear
          @timezones = %w(pacific central eastern)
          Settings do
            site :title => "Default Site Settings" do
              timezones :value => Proc.new { %w(pacific central eastern) }
            end
          end
        end
        
        should "have a proc as a value" do
          assert_kind_of Proc, Settings["site.timezones.value"]
        end
        
        should "be able to call the proc" do
          assert @timezones, Settings["site.timezones.value"].call
        end
      end
      
      context "should be able to take a large dsl and make something of it!" do
        
        setup do
          Settings.clear
          load_settings
        end
        
        should "find the nested teaser" do
          assert_equal 2, Settings["site.teasers.right"].value
        end
        
      end
      
    end
    
    context "setting categories" do
      
      setup do
        Settings.clear
        load_settings
      end
      
      should "be able to get settings by category" do
        [:site, :asset].each do |type|
          assert Settings[type].keys
        end
      end

      should "traverse categories" do
        Settings(:site).each_setting do |key, attributes, value|
          assert attributes
          #puts "Key: #{key.to_s}, Attributes: #{attributes.inspect}, Value: #{value.inspect}"
        end
      end
      
    end
    
    teardown { Settings.clear }
    
  end
  
end