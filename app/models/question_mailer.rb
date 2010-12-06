class QuestionMailer < Mailer
  unloadable
  
  def asked_question(journal)
    question = journal.question
    subject "[Question #{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"
    recipients question.assigned_to.mail unless question.assigned_to.nil?
    @from  = "#{question.author.name} (Redmine) <#{Setting.mail_from}>" unless question.author.nil?
    redmine_headers 'Issue-Id' => question.issue.id
    redmine_headers 'Question-Asked' => question.author.login if question.author.present?
    redmine_headers 'Question-Assigned-To' => question.assigned_to.login if question.assigned_to.present?

    body({
      :question => question,
      :issue => question.issue,
      :journal => journal,
      :issue_url => url_for(:controller => 'issues', :action => 'show', :id => question.issue)
    })

    RAILS_DEFAULT_LOGGER.debug 'Sending QuestionMailer#asked_question'
    render_multipart('asked_question', body)
  end
  
  def answered_question(question, closing_journal)
    subject "[Answered #{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"

    recipients question.author.mail unless question.author.nil?
    @from = "#{question.assigned_to.name} (Redmine) <#{Setting.mail_from}>" unless question.assigned_to.nil?
    redmine_headers 'Issue-Id' => question.issue.id
    redmine_headers 'Question-Answer' => "#{question.issue.id}-#{closing_journal.id}"

    body({
      :question => question,
      :issue => question.issue,
      :journal => closing_journal,
      :issue_url => url_for(:controller => 'issues', :action => 'show', :id => question.issue)
    })

    RAILS_DEFAULT_LOGGER.debug 'Sending QuestionMailer#answered_question'
    render_multipart('answered_question', body)
  end
  
end
