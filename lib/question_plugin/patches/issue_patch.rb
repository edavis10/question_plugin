module QuestionPlugin
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
    
        base.send(:include, InstanceMethods)
    
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :questions
          has_many :open_questions, lambda { Question.opened }, :class_name => 'Question'
    
          include ActionView::Helpers::TextHelper # for truncate
        end
      end
    
      module ClassMethods
      end
    
      module InstanceMethods
        def pending_question?(user)
          self.open_questions.all.each do |question|
            return true if question.assigned_to == user || question.for_anyone?
          end
          return false
        end
    
        def pending_questions(user)
          q = []
          self.open_questions.all.each do |question|
            q << question if question.assigned_to == user || question.for_anyone?
          end
          return q
        end
    
        def close_pending_questions(user, closing_journal)
          self.pending_questions(user).each do |question|
            question.close!(closing_journal) 
          end
        end
    
        def formatted_questions
          open_questions.collect do |question|
            truncate(question.journal.notes, :length => Question::TruncateTo)
          end.join(", ")
        end
      end
    end
  end
end
