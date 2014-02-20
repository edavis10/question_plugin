module QuestionPlugin
  module Patches
    module QueriesHelperPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
    
        base.send(:include, InstanceMethods)
    
        base.class_eval do
          unloadable 
          alias_method_chain :column_content, :question
        end
      end
      
      module ClassMethods
      end
      
      module InstanceMethods
        

        # removed format_questions for compatibility with redmine >= 2.3
        # see http://www.redmine.org/boards/3/topics/37345, 
        #     http://www.redmine.org/issues/13753       
        def column_content_with_question(column, issue)
          if column.name == :formatted_questions
            return '' if issue.open_questions.empty?
            html = '<ol>'
            issue.open_questions.each do |question|
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
          else
            column_content_without_question(column, issue)
          end
        end
        
      end
    end
  end
end
