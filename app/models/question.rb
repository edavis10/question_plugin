class Question < ActiveRecord::Base
  unloadable
  TruncateTo = 120
  
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :issue
  belongs_to :journal
  
  validates_presence_of :author
  validates_presence_of :issue
  validates_presence_of :journal

  named_scope :opened, :conditions => {:opened => true}
  named_scope :for_user, lambda {|user|
    { :conditions => {:assigned_to_id => user.id }}
  }
  named_scope :by_user, lambda {|user|
    { :conditions => {:author_id => user.id }}
  }

  delegate :notes, :to => :journal, :allow_nil => true
  
  def for_anyone?
    self.assigned_to.nil?
  end
  
  def close!(closing_journal=nil)
    if self.opened
      self.opened = false
      if self.save && closing_journal
        QuestionMailer.deliver_answered_question(self, closing_journal)
      end
    end
  end

  # TODO: refactor to named_scope
  def self.count_of_open_for_user(user)
    Question.count(:conditions => {:assigned_to_id => user.id, :opened => true})
  end

  # TODO: refactor to named_scope
  def self.count_of_open_for_user_on_project(user, project)
    Question.count(:conditions => ["#{Question.table_name}.assigned_to_id = ? AND #{Project.table_name}.id = ? AND #{Question.table_name}.opened = ?",
                                   user.id,
                                   project.id,
                                   true],
                   :include => [:issue => [:project]])
  end
end
