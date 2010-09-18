class User < ActiveRecord::Base
  include Cockpit
  
  cockpit :active_record do
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
  end
end
