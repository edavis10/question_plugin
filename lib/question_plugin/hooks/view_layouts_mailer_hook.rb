module QuestionPlugin
  module Hooks
    # Hooks into the email layout to add question content
    class ViewLayoutsMailerHook < Redmine::Hook::ViewListener

      def view_layouts_mailer_html_before_content(context={})
        if has_question?(context)
          journal = context[:journal]
          return "<h1>#{l(:text_question_for) } #{ journal.question.assigned_to.name }</h1>\n"
        else
          return ''
        end
      end

      def view_layouts_mailer_plain_before_content(context={})
        if has_question?(context)
          journal = context[:journal]
          return "#{l(:text_question_for) } #{ journal.question.assigned_to.name }\n\n"
        else
          return ''
        end
      end

      private

      def has_question?(context)
        context[:journal].present? && context[:journal].question.present?
      end

    end
  end
end
