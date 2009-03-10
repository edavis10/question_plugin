class QuestionMailer < Mailer
  def asked_question(journal)
    question = journal.question
    subject "[Question ##{question.issue.id}] #{question.issue.subject}"
    recipients question.assigned_to.mail unless question.assigned_to.nil?
    @from  = "#{question.author.name} (Redmine) <#{Setting.mail_from}>" unless question.author.nil?

    body = {
      :question => question,
      :issue => question.issue,
      :journal => journal,
      :issue_url => url_for(:controller => 'issues', :action => 'show', :id => question.issue)
    }

    part :content_type => "text/plain", :body => render_message("asked_question.erb", body)
    part :content_type => "text/html", :body => render_message("asked_question.text.html.rhtml", body)

    RAILS_DEFAULT_LOGGER.debug 'Sending QuestionMailer#asked_question'
  end
  
  def answered_question(question, closing_journal)
    subject "[Answered] #{question.issue.subject} ##{question.issue.id}"
    recipients question.author.mail unless question.author.nil?
    @from = "#{question.assigned_to.name} (Redmine) <#{Setting.mail_from}>" unless question.assigned_to.nil?

    body = {
      :question => question,
      :issue => question.issue,
      :journal => closing_journal,
      :issue_url => url_for(:controller => 'issues', :action => 'show', :id => question.issue)
    }

    part :content_type => "text/plain", :body => render_message("answered_question.erb", body)
    part :content_type => "text/html", :body => render_message("answered_question.text.html.rhtml", body)

    RAILS_DEFAULT_LOGGER.debug 'Sending QuestionMailer#answered_question'
  end
  
end
