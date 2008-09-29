# == Schema Information
# Schema version: 20080929055605
#
# Table name: books
#
#  id           :integer         not null, primary key
#  cover        :string(255)
#  author       :string(255)
#  title        :string(255)
#  publisher    :string(255)
#  published_at :string(255)
#  content      :text
#  toc          :text
#  problems     :text
#  state        :string(255)
#  note         :string(255)
#  isbn         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Book < ActiveRecord::Base
  acts_as_state_machine :initial => :on_shelf
  
  file_column :cover
  validates_file_format_of :cover, :in => ['jpg', 'gif', 'png']
  
  named_scope :filter, lambda { |args| {:conditions => "title LIKE '%#{args}%' OR author LIKE '%#{args}%' OR publisher LIKE '%#{args}%' OR content LIKE '%#{args}%' OR isbn LIKE '%#{args}%' OR note LIKE '%#{args}%"}}
  
  state :on_shelf
  state :rentout
  
  event :rent do
    transitions :from => :on_shelf, :to => :rentout
  end
  
  event :return do
    transitions :from => :rentout, :to => :on_shelf
  end
  
  def rent_to(user)
    rent!
    
    @log = RentLog.new
    @log.book_id = self.id
    @log.user_id = user.id
    @log.start_date = DateTime.now
    @log.save
  end
  
  def return_book
    return!
    
    @log = RentLog.find(:first, :conditions => ['book_id = ?', self.id])
    @log.end_date = DateTime.now
    @log.save
  end
end
