module QuestionPlugin
  module Hooks
    # Hooks into the email layout to add question content
    class ViewLayoutsMailerHook < Redmine::Hook::ViewListener

      def view_layouts_mailer_html_before_content(context={})

        response_string = ''

        if has_answer?(context)
          response_string += "<h1>#{l(:text_question_answered) }</h1>\n"
        end
        
        if has_question?(context)
          journal = context[:journal]
          response_string += "<h1>#{l(:text_question_for) } #{ journal.question.assigned_to.name }</h1>\n"
        end

        return response_string
      end

      def view_layouts_mailer_plain_before_content(context={})
        response_string = ''

        if has_answer?(context)
          response_string += "#{l(:text_question_answered) }\n\n"
        end

        if has_question?(context)
          journal = context[:journal]
          response_string += "#{l(:text_question_for) } #{ journal.question.assigned_to.name }\n\n"
        end

        return response_string
      end

      private

      def has_question?(context)
        context[:journal].present? && context[:journal].question.present?
      end

      def has_answer?(context)
        context[:journal].present? &&
          context[:journal].issue.present? &&
          context[:journal].issue.pending_question?(context[:journal].user)
        
      end

    end
  end
end
