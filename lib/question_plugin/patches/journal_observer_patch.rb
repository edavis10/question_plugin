module QuestionPlugin
  module Patches
    module JournalObserverPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :after_create, :question
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def after_create_with_question(journal)
          after_create_without_question(journal)

          if journal.is_a?(IssueJournal)
            if journal.question
              journal.question.save
              QuestionMailer.deliver_asked_question(journal)
            end

            # Close any open questions
            if journal.journaled.present? && journal.journaled.pending_question?(journal.user)
              journal.journaled.close_pending_questions(journal.user, journal)
            end
          end
          

        end
        
      end
    end
  end
end
