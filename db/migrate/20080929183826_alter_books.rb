class AlterBooks < ActiveRecord::Migration
  def self.up
    change_column :books, :note, :text
  end

  def self.down
    # Sorry, one way ticket.
  end
end
