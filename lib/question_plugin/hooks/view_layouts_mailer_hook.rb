module QuestionPlugin
  module Hooks
    # Hooks into the email layout to add question content
    class ViewLayoutsMailerHook < Redmine::Hook::ViewListener

      def view_layouts_mailer_html_before_content(context={})
        return render_response_string(context, :html)
      end

      def view_layouts_mailer_plain_before_content(context={})
        return render_response_string(context, :plain)
      end

      private

      def render_response_string(context, format)
        response_string = ''

        if has_answer?(context)
          response_string += if format == :html
                               "<h1>#{l(:text_question_answered) }</h1>\n"
                             else
                               "#{l(:text_question_answered) }\n\n"
                             end
        end
        
        if has_question?(context)
          journal = context[:journal]
          response_string += if format == :html
                               "<h1>#{l(:text_question_for) } #{ journal.question.assigned_to.name }</h1>\n"
                             else
                               "#{l(:text_question_for) } #{ journal.question.assigned_to.name }\n\n"
                             end
        end

        response_string
      end

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
