require File.join(File.dirname(__FILE__), 'test_helper')

class SettingsTest < ActiveSupport::TestCase
  
  context "Database Store" do
    
    setup do
      Settings.clear
      Settings.store = :db
    end
    
    should "have a db as a store" do
      assert_kind_of Cockpit::Store::Database, Settings.store
    end
    
    context "save to the database" do
      
      setup do
        Settings["lantial"] = "to database"
        Settings["pollard"] = "another"
      end
      
      should "have saved lance into the database" do
        assert_equal "to database", Setting.find_by_key("lantial").value
      end
      
      should "be able to change a database record through tree" do
        assert_equal "another", Setting.find_by_key("pollard").value
        Settings["pollard"] = "first change"
        assert_equal "first change", Setting.find_by_key("pollard").value
      end
      
      should "NOT be able to change a database record independently of the tree" do
        setting = Setting.find_by_key("pollard")
        assert_equal "another", setting.value
        setting.value = "changed!"
        setting.save
        
        assert_equal "changed!", Setting.find_by_key("pollard").value
        assert_equal "changed!", Settings["pollard"].value
      end
      
      context "get value" do
        
        setup do
          Settings.store = :db
          Settings.clear(:hard => true)
        end
        
        should "be able to get a previously created setting from the db" do
          assert_equal Cockpit::TreeHash.new, Settings.tree
          Setting.create(:key => "lantial", :value => "custom value")
          assert_equal "custom value", Settings["lantial"].value
          assert_equal({:lantial => {:type => :string, :value => "custom value"}}, Settings.tree)
        end
        
        should "be able to save objects using other syntax" do
          key = "im.a.nested.key"
          value = "wow"
          assert_equal nil, Setting.find_by_key(key)
          Settings.im.a.nested.key = value
          assert_equal value, Settings(key).value
          # PENDING!
          # assert_equal value, Setting.find_by_key(key)
          Settings("im.nesting.myself" => "here")
          assert_equal "here", Setting.find_by_key("im.nesting.myself").value
          Settings["me.too.please"] = "let me in"
          assert_equal "let me in", Setting.find_by_key("me.too.please").value
          Settings.set("finally.me" => "too")
          assert_equal "too", Setting.find_by_key("finally.me").value
        end
        
      end
      
      context "should not save large tree to database" do
        
        setup do
          Settings.clear
          load_settings
        end
        
        should "find nested objects in database" do
          assert_equal nil, Setting.find_by_key("site.title")
        end
        
      end
      
      context "should find setting" do
        
        setup do
          Settings.store = :db
          Settings("lantial" => "saved")
        end
        
        should "find the thing" do
          setting = Setting.find("lantial")
          assert setting
        end
        
        teardown do
          Settings.store = :memory
        end
        
      end
      
    end
    
    should "be able to switch the store without modifying the tree" do
      # pending
    end
    
    context "type casting" do
      
      setup do
        @datetime = DateTime.now
        @time     = Time.now
        Settings.store = :db
        Setting.detonate
        Settings["a.string"] = "string"
        Settings["a.boolean"] = true
        Settings["a.false_boolean"] = false
        Settings["a.integer"] = 10
        Settings["a.float"] = 10.11
        Settings["a.datetime"] = @datetime
        Settings["a.time"] = @time
      end
      
      should "parse types" do
        assert_equal "string",        Setting.find("a.string").value
        assert_equal true,            Setting.find("a.boolean").value
        assert_equal false,           Setting.find("a.false_boolean").value
        assert_equal 10,              Setting.find("a.integer").value
        assert_equal 10.11,           Setting.find("a.float").value
        assert_equal @time.to_s,      Setting.find("a.time").value.to_s
      end
      
      should "parse datetime" do
        # close but not quite
        # assert_equal @datetime, Setting.find("a.datetime").value
        # pending
      end
      
      teardown do
        Setting.detonate
      end
      
    end
    
    teardown { Settings.clear }
    
  end
  
end