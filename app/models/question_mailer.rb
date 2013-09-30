class QuestionMailer < Mailer
  unloadable
  
  def asked_question(journal)
    question = journal.question

    if Setting.plugin_question_plugin[:obfuscate_author] == "1"
      # Obfuscate author infos
      from = "#{Setting.app_title} <#{Setting.mail_from}>"
    else
      # Clear author infos
      from = question.author ? "#{question.author.name} (#{l(:field_system_name)} - #{I18n.t(:text_question)}) <#{Setting.mail_from}>" : nil
    end
    to = question.assigned_to ? question.assigned_to.mail : nil
    subject = "[#{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"
    
    @from = from
    @question = question
    @issue = question.issue
    @journal = journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => question.issue)

    redmine_headers 'Issue-Id' => question.issue.id
    redmine_headers 'Question-Asked' => question.author.login if question.author.present?
    redmine_headers 'Question-Assigned-To' => question.assigned_to.login if question.assigned_to.present?

    Rails.logger.debug 'Sending QuestionMailer#asked_question'
    mail(:from => from, :to => to, :subject => subject)
  end
  
  def answered_question(question, closing_journal)
    if Setting.plugin_question_plugin[:obfuscate_author] == "1"
      # Obfuscate author infos
      from = "#{Setting.app_title} <#{Setting.mail_from}>"
      @from = from
    else
      # Clear author infos
      from = question.assigned_to ? "#{question.assigned_to.name} (#{l(:field_system_name)} - #{I18n.t(:text_answer)}) <#{Setting.mail_from}>" : nil
      @from = "#{question.assigned_to.name} (#{l(:field_system_name)} - #{I18n.t(:text_answer)}) <#{Setting.mail_from}>" unless question.assigned_to.nil?
    end
    to = question.author ? question.author.mail : nil
    subject =  "[#{question.issue.project.name} ##{question.issue.id}] #{question.issue.subject}"

    @question = question
    @issue = question.issue
    @journal = closing_journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => question.issue)

    redmine_headers 'Issue-Id' => question.issue.id
    redmine_headers 'Question-Answer' => "#{question.issue.id}-#{closing_journal.id}"

    Rails.logger.debug 'Sending QuestionMailer#answered_question'
    mail(:from => from, :to => to, :subject => subject)
  end

  # Creates an email with a list of issues that have open questions
  # assigned to the user
  def question_reminder(user, issues)
    set_language_if_valid user.language

    to = user.mail
    subject = l(:question_reminder_subject, :count => issues.size)

    @issues = issues
    @issues_url = url_for(:controller => 'issuequestions', :action => 'my_issue_filter')

    redmine_headers 'Type' => 'Question'

    mail(:to => to, :subject => subject)
  end

  # Send email reminders to users who have open questions.
  def self.question_reminders
    open_questions_by_assignee = Question.opened.order('id desc').all.group_by(&:assigned_to)

    open_questions_by_assignee.each do |assignee, questions|
      next unless assignee.present? and not assignee.locked?

      issues = questions.reject {|q| not q.issue.visible?(assignee) }.collect {|q| q.issue }.uniq
      next if issues.count == 0

      question_reminder(assignee, issues).deliver
    end
  end
end
