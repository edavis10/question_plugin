class QuestionMailer < Mailer
  unloadable
  
  def asked_question(journal)
    question = journal.question
    subject "[Frage #{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"
    recipients question.assigned_to.mail unless question.assigned_to.nil?
    @from  = "#{question.author.name} (#{l(:field_system_name)}) <#{Setting.mail_from}>" unless question.author.nil?
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
    subject "[Beantwortet #{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"

    recipients question.author.mail unless question.author.nil?
    @from = "#{question.assigned_to.name} (#{l(:field_system_name)}) <#{Setting.mail_from}>" unless question.assigned_to.nil?
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

  # Creates an email with a list of issues that have open questions
  # assigned to the user
  def question_reminder(user, issues)
    redmine_headers 'Type' => "Question"
    set_language_if_valid user.language
    recipients user.mail
    subject l(:question_reminder_subject, :count => issues.size)
    body :issues => issues,
         :issues_url => url_for(:controller => 'questions', :action => 'my_issue_filter')
    render_multipart('question_reminder', body)
  end

  # Send email reminders to users who have open questions.
  def self.question_reminders

    open_questions_by_assignee = Question.opened.all(:order => 'id desc').group_by(&:assigned_to)

    open_questions_by_assignee.each do |assignee, questions|
      next unless assignee.present?

      issues = questions.collect {|q| q.issue.visible?(assignee) ? q.issue : nil }.compact.uniq
      next if issues.count == 0

      deliver_question_reminder(assignee, issues)
    end
  end
end
