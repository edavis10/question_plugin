class QuestionKanbanHooks < QuestionHooksBase
  def view_kanbans_issue_details(context = {})
# GREY when there are no questions - (question count is 0)
# RED when all questions unanswered - (question count is equal to the unanswered question count)
# GREEN when all questions is answered and no new note by the "assigned to" person - (question count is not 0 and unanswered question count is 0 and the last journal author is not the assigned to)
# ORANGE if some questions are answered and the "assigned to" person has added a note - (question count is not 0 and unanswered question count is less than the total question count and the last journal author is the assigned to)
# BLACK if all questions are answered and the "assigned to" person has added a note - (question count is not 0 and unanswered question count is 0 and the last journal author is the assigned to)
# A Tool-tip that displays how many questions are answered/unanswered (e.g. 2/4 questions answered, 0 questions, 4/4 questions answered)

    
    issue = context[:issue]

    if issue.questions.count == 0
      return question_icon('c6c6c6') # gray
    end
    
    if issue.questions.count == issue.open_questions.count
      return question_icon('ff0000') # red
    end

    if issue.questions.count != 0 && issue.open_questions.count == 0 && issue.journals.last && issue.journals.last.user != issue.assigned_to
      return question_icon('005829') # green
    end

    if issue.questions.count != 0 && issue.open_questions.count <= issue.questions.count && issue.journals.last.user == issue.assigned_to
      return question_icon('dd6a06') # orange
    end

    if issue.open_questions.count == 0 && issue.journals.last.user == issue.assigned_to
      return question_icon('000000') # black
    end

    return ''
  end

  protected

  def question_icon(color)
    "<span class='kanban-question' style='color: ##{color}'>?</span>"
  end
end
