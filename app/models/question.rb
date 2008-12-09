class Question < ActiveRecord::Base
  extend ActionView::Helpers::TextHelper
  
  TruncateTo = 120
  
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :issue
  belongs_to :journal
  
  validates_presence_of :author
  validates_presence_of :issue
  validates_presence_of :journal
  
  def self.formatted_list(questions)
    list = []
    questions.each do |question|
      if question.journal && !question.journal.notes.blank?
        list << truncate(question.journal.notes, TruncateTo)
      end
    end
    
    return list
  end
end
