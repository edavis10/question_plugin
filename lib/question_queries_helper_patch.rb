require_dependency 'queries_helper'

module QuestionQueriesHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method :default_column_content, :column_content
      alias_method :column_content, :question_column_content
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def question_column_content(column, issue)
      if column.name == :formatted_questions
        return issue.formatted_questions
      else
        default_column_content(column, issue)
      end
    end
  end
end

QueriesHelper.send(:include, QuestionQueriesHelperPatch)
