module QuestionPlugin
  module Patches
    module JournalPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_one :question, :dependent => :destroy
          
          #
          # used for redmine >= 2.3.2
          #
          alias_method_chain :send_notification, :question unless ActiveSupport::Dependencies::search_for_file('journal_observer')
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def send_notification_with_question
            send_notification_without_question
            if journal.question
              QuestionMailer.asked_question(self).deliver
            end
        end
      end
    end
  end
end
