class CreateRentLogs < ActiveRecord::Migration
  def self.up
    create_table :rent_logs do |t|
      t.column :book_id, :integer
      t.column :user_id, :integer
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :rent_logs
  end
end
