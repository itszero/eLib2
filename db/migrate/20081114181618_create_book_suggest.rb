class CreateBookSuggest < ActiveRecord::Migration
  def self.up
    create_table :suggests do |t|
      t.column :title, :string
      t.column :author, :string
      t.column :publisher, :string
      t.column :reason, :string
      t.column :url, :string
      t.column :state, :string
      t.column :user_id, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :suggests
  end
end
