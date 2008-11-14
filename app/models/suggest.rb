class Suggest < ActiveRecord::Base
  belongs_to :user
  acts_as_state_machine :initial => :wait
  
  state :wait
  state :accept
  state :reject
  
  event :accept do
    transitions :from => :wait, :to => :accept
    transitions :from => :reject, :to => :accept
  end
  
  event :reject do
    transitions :from => :wait, :to => :reject
    transitions :from => :accept, :to => :reject
  end
  
  event :reset do
    transitions :from => :accept, :to => :wait
    transitions :from => :reject, :to => :wait
  end
end
