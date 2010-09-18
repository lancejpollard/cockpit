class User < ActiveRecord::Base  
  attr_accessor :name, :car
  
  cockpit do
    implicitly_typed do
      string      "Lance"
      array       %w(red green blue)
      integer     1
      float       1.0
      datetime    Time.parse("01-01-2001")
    end
    
    explicitly_typed do
      string      "Lance",                String
      array       %w(red green blue),     Array
      integer     1,                      Integer
      float       1.0,                    Float
      datetime    Time.parse("01-01-2001"),               Time
      invalid do
        string      1,                    String
        array       "red green blue",     Array
        integer     "1",                  Integer
        float       "1.0",                Float
        datetime    "Time.now",           Time
      end
    end
    
    with_attributes do
      string      "Lance",                String, :title => "A String"
      array       %w(red green blue),     Array, :title => "Colors", :options => %w(red green blue yellow black white)
    end
    
    settings_with_callbacks do
      name "Lance", :after => :set_name
      car "Honda", :before => lambda { self.car = "Accord" }
      nope "I'm invalid", :if => lambda { |key, value|
        !self.is_a?(User)
      }
      birthday DateTime,
        :before => lambda { |key|
          self.name ||= "Lance"
        },
        :after => :queue_birthday_message,
        :if => lambda { |key, value|
          value =~ /\d\d\/\d\d\/\d\d\d\d/ # 10/03/1986
        }
    end
  end
  
  def set_name(key, value)
    self.name = value
  end
  
  def queue_birthday_message
  end
end
