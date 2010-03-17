module QuestionIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :questions
      has_many :open_questions, :class_name => 'Question', :conditions => { :opened => true }

      include ActionView::Helpers::TextHelper # for truncate
      
      class << self
        # I dislike alias method chain, it's not the most readable backtraces
        alias_method :default_find, :find
        alias_method :find, :find_with_questions_added_to_the_includes

        alias_method :default_count, :count
        alias_method :count, :count_with_questions_added_to_the_includes

        alias_method :default_sum, :sum
        alias_method :sum, :sum_with_questions_added_to_the_includes
      end
    end

  end
  
  module ClassMethods
    def find_with_questions_added_to_the_includes(*args)
      scan_for_options_hash_and_add_includes_if_needed(args)
      default_find(*args)
    end

    def count_with_questions_added_to_the_includes(*args)
      scan_for_options_hash_and_add_includes_if_needed(args)
      default_count(*args)
    end
    
    def sum_with_questions_added_to_the_includes(*args)
      scan_for_options_hash_and_add_includes_if_needed(args)
      default_sum(*args)
    end
    
    private
    
    # Finds the options hash. If question is part of the conditions then
    # add questions to the includes
    def scan_for_options_hash_and_add_includes_if_needed(args)
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

