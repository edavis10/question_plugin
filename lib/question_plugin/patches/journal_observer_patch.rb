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
        # Utility method to check if the journal update will be handled
        # by the core's observer.
        def will_be_sent_notification_from_main_observer?(journal, mail_to)
          issue = journal.journaled
          if Setting.notified_events.include?('issue_updated') ||
              (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
              (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
              (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
            (issue.recipients + issue.watcher_recipients).include?(mail_to)
          end
        end
        
        def after_create_with_question_assigned_to(journal)
          if journal.question
            journal.question.save
          end

          journal.reload # To get journal.user

          if journal && journal.journaled.present? && journal.is_a?(IssueJournal) && journal.question.present? && journal.question.assigned_to.present?
            mail_to = journal.question.assigned_to.mail

            unless will_be_sent_notification_from_main_observer?(journal, mail_to)
              Mailer.deliver_issue_edit(journal, mail_to)
            end
          end
          
          after_create_without_question_assigned_to(journal)

          # Close any open questions
          if journal.journaled && journal.journaled.pending_question?(journal.user)
            journal.journaled.close_pending_questions(journal.user, journal)
          end

        end
        
      end
    end
  end
end
