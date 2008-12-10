class QuestionMailer < Mailer
  def asked_question(journal)
    question = journal.question
    subject "[Question] #{question.issue.subject} ##{question.issue.id}"
    recipients question.assigned_to.mail unless question.assigned_to.nil?

    body(:question => question,
         :issue => question.issue,
         :journal => journal,
         :issue_url => url_for(:controller => 'issues', :action => 'show', :id => question.issue))
    
  end
end
