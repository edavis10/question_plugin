module QuestionPlugin
  module Hooks
    class ViewUserKanbansShowContextualTopHook < Redmine::Hook::ViewListener
      # Adds a link showing the questions for the current user
      def view_user_kanbans_show_contextual_top(context={})
        user = User.current
        if user
          count = Question.count_of_open_for_user(user)

          if count > 0
            return link_to(l(:field_formatted_questions) + " (#{count})",
                           {
                             :controller => 'questions',
                             :action => 'user_issue_filter',
                             :user_id => user.id,
                             :only_path => true
                           }, { :class => 'question-link' })
          end
        end
      end
    end
  end
end
