ActiveRecord::Schema.define(:version => 0) do

  create_table "units", :force => true do |t|
    t.integer  "capacity"
  end

  create_table "unit_translations", :force => true do |t|
    t.references :unit
    t.string "name"
    t.string "title"
    t.string "locale"
  end

end
