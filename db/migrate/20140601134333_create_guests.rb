class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :dev_type, :size => "computer".length
      t.string :label
      t.timestamps
      t.timestamp :active_at
      t.string :governor
      t.text :governor_data
    end
  end
end
