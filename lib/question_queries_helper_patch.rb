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
        return format_questions(issue.open_questions)
      else
        default_column_content(column, issue)
      end
    end
    
    def format_questions(questions)
      return '' if questions.empty?
      html = '<ol>'
      questions.each do |question|
        html << "<li>"
        html << "  <div class='tooltip'>"
        html << "    <span class='question_summary'>"
        html << link_to(h(truncate(question.journal.notes, :length => Question::TruncateTo)),
                        :controller => 'issues',
                        :action => 'show',
                        :id => question.issue,
                        :anchor => "question-#{question.id}")
        html << "    </span>"
        html << "    <span class='tip'>"
        html << link_to_issue(question.issue)
        html << ": #{h(question.journal.notes)}<br /><br />"
        html << "<strong>#{l(:question_text_asked_by)}</strong>: #{question.author.to_s}<br />"
        html << "<strong>#{l(:question_text_assigned_to)}</strong>: #{question.assigned_to.to_s}<br />"
        html << "<strong>#{l(:question_text_created_on)}</strong>: #{format_date(question.journal.created_on)}"
        html << "    </span>"
        html << "  </div>"
        html << "</li>"
      end
      html << '</ol>'
      return html
    end
  end
end


