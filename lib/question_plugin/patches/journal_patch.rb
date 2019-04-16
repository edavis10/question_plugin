module QuestionPlugin
  module Patches
    module JournalPatch
      def self.included(base)
        
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_one :question, :dependent => :destroy
          

          class << self
            alias_method_chain :preload_journals_details_custom_fields,  :question
          end

          #
          # used for redmine >= 2.3.2
          #
          alias_method_chain :send_notification, :question unless ActiveSupport::Dependencies::search_for_file('journal_observer')
        end
      end
      
      module ClassMethods
        def preload_journals_details_custom_fields_with_question(journals)
          
          # preload questions for all journal entries for faster display
          ActiveRecord::Associations::Preloader.new.preload(journals, :question)
          
          preload_journals_details_custom_fields_without_question(journals)
        end
      end

      module InstanceMethods
        def send_notification_with_question
            send_notification_without_question
            if question
              QuestionMailer.asked_question(self).deliver
            end
        end
      end
    end
  end
end
