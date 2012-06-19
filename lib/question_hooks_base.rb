class QuestionHooksBase < Redmine::Hook::ViewListener
  # Have to inclue Gravatars because ApplicationHelper will not get it
  include Gravatarify::Helper
  
  protected
  
  def assigned_question_html(question)
    html = "<span class=\"question-line\">"
    html << "  <a name=\"question-#{h(question.id)}\" href=\"#question-#{h(question.id)}\">"
    html << "#{l(:text_question_for)} #{question.assigned_to.to_s}"
    html << "  </a>"
    html << "<span>#{avatar(question.assigned_to, { :size => 16, :class => '' })}</span> </span>" if question.assigned_to && question.assigned_to.mail
    html
  end
  
  def unassigned_question_html(question)
    html = "<span class=\"question-line\">"
    html << "  <a name=\"question-#{h(question.id)}\" href=\"#question-#{h(question.id)}\">"
    html << l(:text_question_for_anyone)
    html << "  </a>"
    html << "</span>"
    html
  end
end
