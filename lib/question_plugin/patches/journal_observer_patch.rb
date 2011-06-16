module QuestionPlugin
  module Patches
    module JournalObserverPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :after_create, :question_assigned_to
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def after_create_with_question_assigned_to(journal)
          if journal && journal.issue.present? && journal.question.present? && journal.question.assigned_to.present?
            mail_to = journal.question.assigned_to.mail
            issue = journal.issue

            unless (issue.recipients + issue.watcher_recipients).include?(mail_to)
              Mailer.deliver_issue_edit(journal, mail_to)
            end
          end
          
          after_create_without_question_assigned_to(journal)
        end
        
      end
    end
  end
end
