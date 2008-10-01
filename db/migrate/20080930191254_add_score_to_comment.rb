class AddScoreToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :score, :interger
  end

  def self.down
    remove_column :comments, :score
  end
end
