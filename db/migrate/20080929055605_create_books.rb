class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.column :cover, :string
      t.column :author, :string
      t.column :title, :string
      t.column :publisher, :string
      t.column :published_at, :string
      t.column :content, :text
      t.column :toc, :text
      t.column :problems, :text # Problems for homework, YAML formatted
      t.column :state, :string
      t.column :note, :string
      t.column :isbn, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
