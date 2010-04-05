class QuestionKanbanHooks < QuestionHooksBase
  def view_kanbans_issue_details(context = {})
    # GREY when there are no questions - (question count is 0)
    # RED when all questions unanswered - (question count is equal to the unanswered question count)
    # GREEN when all questions is answered and no new note by the "assigned to" person - (question count is not 0 and unanswered question count is 0 and the last journal author is not the assigned to)
    # ORANGE if some questions are answered and the "assigned to" person has added a note - (question count is not 0 and unanswered question count is less than the total question count and the last journal author is the assigned to)
    # BLACK if all questions are answered and the "assigned to" person has added a note - (question count is not 0 and unanswered question count is 0 and the last journal author is the assigned to)
    issue = context[:issue]

    return '' unless issue
    
    if issue.questions.count == 0
      return question_icon(:gray, issue)
    end
    
    if issue.questions.count == issue.open_questions.count
      return question_icon(:red, issue)
    end

    if issue.questions.count != 0 && issue.open_questions.count == 0 && issue.journals.last && issue.journals.last.user != issue.assigned_to
      return question_icon(:green, issue)
    end

    if issue.questions.count != 0 && issue.open_questions.count != 0 && issue.open_questions.count <= issue.questions.count && issue.journals.last.user == issue.assigned_to
      return question_icon(:orange, issue)
    end

    if issue.open_questions.count == 0 && issue.journals.last.user == issue.assigned_to
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
            { :controller => 'issues', :action => 'show', :id => issue })
  end
end
