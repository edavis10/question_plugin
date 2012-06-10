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

    QuestionIssuePatch::ActiveRecord.enable
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

  module ActiveRecord
    def self.enable
      require 'active_record'

      ::ActiveRecord::Calculations.class_eval do
        alias_method :count_before_question, :count
        alias_method :sum_before_question, :sum

        def count(*args)
          QuestionIssuePatch::ActiveRecord::HelperMethods.scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
          count_before_question(*args)
        end

        def sum(*args)
          QuestionIssuePatch::ActiveRecord::HelperMethods.scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
          sum_before_question(*args)
        end
      end

      ::ActiveRecord::FinderMethods.class_eval do
        alias_method :find_before_question, :find
        alias_method :find_ids_before_question, :find_ids

        def find(*args)
          QuestionIssuePatch::ActiveRecord::HelperMethods.scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
          find_before_question(*args)
        end

        def find_ids(*args)
          relation = scan_where_clauses_and_add_includes_if_needed
          relation.find_ids_before_question(*args)
        end

        private

        def scan_where_clauses_and_add_includes_if_needed
          relation = self
          # Ensure passed class inherits from the Issue class
          if relation.klass <= Issue
            @where_values.each do |where_value|
              if where_value.is_a?(String) && where_value.include?('question')
                relation = relation.includes(:questions)
              elsif where_value.is_a?(Array) && where_value[0].include?('question')
                relation = relation.includes(:questions)
              end
            end
          end
          relation
        end
      end
    end

    class HelperMethods
      class << self
        # Finds the options hash. If question is part of the conditions then
        # add questions to the includes
        def scan_for_options_hash_and_add_includes_if_needed(klass, args)
          # Ensure passed class inherits from the Issue class
          if klass <= Issue
            args.each do |arg|
              if arg.is_a?(Hash) && arg[:conditions]
                if arg[:conditions].is_a?(String) && arg[:conditions].include?('question')
                  # String conditions
                  add_questions_to_the_includes(arg)
                elsif arg[:conditions].is_a?(Array) && arg[:conditions][0].include?('question')
                  # Array conditions
                  add_questions_to_the_includes(arg)
                end
              end
            end
          end
        end

        private

        def add_questions_to_the_includes(arg)
          if arg[:include]
            # Has includes
            if arg[:include].is_a?(Hash)
              # Hash includes
              arg[:include] << :questions
            else
              # single includes
              arg[:include] = [ arg[:include] , :questions ]
            end
          else
            # No includes
            arg[:include] = :questions
          end
        end
      end
    end
  end
end
