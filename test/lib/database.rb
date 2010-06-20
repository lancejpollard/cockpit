begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end

ActiveRecord::Base.configurations = true

ActiveRecord::Schema.define(:version => 1) do

  create_table :settings, :force => true do |t|
    t.string :key
    t.string :value
    t.string :cast_as
    t.string :configurable_type
    t.integer :configurable_id
  end
  
  create_table "users", :force => true do |t|
  end

end
