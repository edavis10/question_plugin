class QuestionHooksBase < Redmine::Hook::ViewListener
  # Have to inclue Gravatars because ApplicationHelper will not get it
  include GravatarHelper::PublicMethods
  
  protected
  
  def assigned_question_html(question)
    html = "<span class=\"question-line\">"
    html << " #{l(:text_question_for)} "
    html << link_to_user(question.assigned_to)
    html << "&nbsp;</span>" if question.assigned_to && question.assigned_to.mail
    html
  end
  
  def unassigned_question_html(question)
    html = "<span class=\"question-line\">"
    html << l(:text_question_for_anyone)
    html << "&nbsp;</span>"
    html
  end
end
