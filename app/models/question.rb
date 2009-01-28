class Question < ActiveRecord::Base
  TruncateTo = 120
  
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :issue
  belongs_to :journal
  
  validates_presence_of :author
  validates_presence_of :issue
  validates_presence_of :journal
  
  def for_anyone?
    self.assigned_to.nil?
  end
  
  def close!(closing_journal=nil)
    if self.opened
      self.opened = false
      self.save!
      QuestionMailer.deliver_answered_question(self, closing_journal) if closing_journal
    end
  end
end
