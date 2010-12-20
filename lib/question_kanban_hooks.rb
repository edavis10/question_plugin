class QuestionKanbanHooks < QuestionHooksBase
  def view_kanbans_issue_details(context = {})
    # GREY when there are no questions
    # RED when there are open questions
    # BLACK if all questions are answered
    issue = context[:issue]

    return '' unless issue
    
    if issue.questions.count == 0
      return question_icon(:gray, issue)
    end
    
    if issue.open_questions.count > 0
      return question_icon(:red, issue)
    end

    if issue.questions.count > 0 && issue.open_questions.count == 0
      return question_icon(:black, issue)
    end

    return ''
  end

  # * :user
  def view_kanbans_user_name(context = {})
    user = context[:user]
    if user
      count = Question.count_of_open_for_user(user)

      if count > 0
        return content_tag(:p, link_to(l(:field_formatted_questions) + " (#{count})",
                                       {
                                         :controller => 'questions',
                                         :action => 'user_issue_filter',
                                         :user_id => user.id,
                                         :only_path => true
                                       },
                                       { :class => 'question-link' }))
      end
    end

    return ''

  end

  protected

  def question_icon(color, issue)
    total_questions = issue.questions.count
    open_questions = issue.open_questions.count
    answered_questions = total_questions - open_questions
    
    title = l(:question_text_ratio_questions_answered, :ratio => "#{answered_questions}/#{total_questions}")
    link_to(image_tag("question-#{color}.png", :plugin => 'question_plugin', :title => title, :class => "kanban-question #{color}"),
            { :controller => 'issues', :action => 'show', :id => issue },
            :class => "issue-show-popup issue-#{h(issue.id)}")
  end
end
