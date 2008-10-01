# == Schema Information
# Schema version: 20080930191254
#
# Table name: rent_logs
#
#  id         :integer         not null, primary key
#  book_id    :integer
#  user_id    :integer
#  start_date :datetime
#  end_date   :datetime
#  created_at :datetime
#  updated_at :datetime
#

class RentLog < ActiveRecord::Base
  belongs_to :book
  belongs_to :user
end
