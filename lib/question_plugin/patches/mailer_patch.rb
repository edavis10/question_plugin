module QuestionPlugin
  module Patches
    module MailerPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          def issue_edit_with_question(journal, recipient)
            if journal.present? && journal.question.present?
              question = journal.question
              redmine_headers 'Question-Asked' => question.author.login if question.author.present?
              redmine_headers 'Question-Assigned-To' => question.assigned_to.login if question.assigned_to.present?
            end

            if journal.present? && journal.issue.present? && journal.issue.pending_question?(journal.user)
              redmine_headers 'Question-Answer' => "#{journal.issue.id}-#{journal.id}"
            end
            
            issue_edit_without_question(journal, recipient)
          end
          alias_method_chain :issue_edit, :question

        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
