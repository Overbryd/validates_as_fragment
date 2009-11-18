ActiveRecord::Schema.define(:version => 0) do

  create_table "models", :force => true do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "salt"
    t.string "password_digest"
    t.datetime "date_of_birth"
    t.boolean "incomplete"
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end
end
