module QuestionIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :questions
      has_many :open_questions, :class_name => 'Question', :conditions => { :opened => true }

      include ActionView::Helpers::TextHelper # for truncate
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def pending_question?(user)
      self.open_questions.find(:all).each do |question|
        return true if question.assigned_to == user || question.for_anyone?
      end
      return false
    end

    def close_pending_questions(user, closing_journal)
      self.open_questions.find(:all).each do |question|
        question.close!(closing_journal) if question.assigned_to == user || question.for_anyone?
      end
    end

    def formatted_questions
      open_questions.collect do |question|
        truncate(question.journal.notes, Question::TruncateTo)
      end.join(", ")
    end
  end
end
