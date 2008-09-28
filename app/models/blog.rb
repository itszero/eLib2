# == Schema Information
# Schema version: 20080926035923
#
# Table name: blogs
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Blog < ActiveRecord::Base
end
