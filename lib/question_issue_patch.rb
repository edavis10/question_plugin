require_dependency 'issue'

module QuestionIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :questions
      
      class << self
        alias_method :default_find, :find
        alias_method :find, :find_with_questions_added_to_the_includes

        alias_method :default_count, :count
        alias_method :count, :count_with_questions_added_to_the_includes
      end
    end

  end
  
  module ClassMethods
    def find_with_questions_added_to_the_includes(*args)
      # Second args is the options Hash
      if args[1] &&
          args[1].is_a?(Hash) &&
          args[1][:conditions] &&
          args[1][:conditions].include?('question')
        # Add questions to includes
        
        if args[1][:include]
          if args[1][:include].is_a?(Hash)
            # Hash includes
            args[1][:include] << :questions
          else
            # single includes
            args[1][:include] = [ args[1][:include] , :questions ]
          end
        else
          # No includes
          args[1][:include] = :questions
        end
      end
      default_find(*args)
    end

    def count_with_questions_added_to_the_includes(*args)
      # find the options hash and if question is part of the conditions
      args.each do |arg|
        if arg.is_a?(Hash) && arg[:conditions] && arg[:conditions].include?('question')
          # Add questions to includes
          if arg[:include]
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
      default_count(*args)
    end
  end
  
  module InstanceMethods
  end
end

Issue.send(:include, QuestionIssuePatch)
