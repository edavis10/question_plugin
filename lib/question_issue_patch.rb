require_dependency 'issue'

module QuestionIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :questions

      class << self
        # I dislike alias method chain, it's not the most readable backtraces
        alias_method :default_find, :find
        alias_method :find, :find_with_questions_added_to_the_includes

        alias_method :default_count, :count
        alias_method :count, :count_with_questions_added_to_the_includes
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
    
    private
    
    # Finds the options hash. If question is part of the conditions then
    # add questions to the includes
    def scan_for_options_hash_and_add_includes_if_needed(args)
      args.each do |arg|
        if arg.is_a?(Hash) && arg[:conditions] && arg[:conditions].include?('question')
          # Add questions to includes
          add_questions_to_the_includes(arg)
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
    def formatted_questions
      return '' if self.questions.empty?
      html = '<ol>'
      Question.formatted_list(self.questions).each do |question|
        html << "<li>" + question + "</li>"
      end
      html << '</ol>'
      return html
    end
  end
end

Issue.send(:include, QuestionIssuePatch)
