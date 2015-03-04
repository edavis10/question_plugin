class Question < ActiveRecord::Base
  unloadable
  TruncateTo = 120
  
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :issue
  belongs_to :journal, :class_name => "Journal", :foreign_key => "journal_id"
  
  validates_presence_of :author
  validates_presence_of :issue
  validates_presence_of :journal
  
  attr_protected :journal

  scope :opened, lambda { where(:opened => true) }
  scope :not_hidden, lambda { where(:hidden => false) }

  scope :for_user, lambda {|user|
     where(:assigned_to_id => user.id)
  }
  scope :by_user, lambda {|user|
     where(:author_id => user.id)
  }

  delegate :notes, :to => :journal, :allow_nil => true
  
  def for_anyone?
    self.assigned_to.nil?
  end
  
  def close!(closing_journal=nil)
    if self.opened
      self.opened = false
      if self.save && closing_journal
        QuestionMailer.answered_question(self, closing_journal).deliver
      end
    end
  end
  
  # TODO: refactor to named_scope
  def self.count_of_open_for_user(user)
    Question.where(:assigned_to_id => user.id, :opened => true).count
  end

  # TODO: refactor to named_scope
  def self.count_of_open_for_user_on_project(user, project)
    Question.where(["(#{Question.table_name}.assigned_to_id = ?) AND #{project.project_condition(Setting.display_subprojects_issues?)} AND (#{Question.table_name}.opened = ?)",
                    user.id, true]).
             joins(:issue => :project).preload(:project).count
  end
end
