class QuestionIssueHooks < QuestionHooksBase
  # Applies the question class to each journal div if they are questions
  def view_issues_history_journal_bottom(context = { })
    o = ''
    if context[:journal] && context[:journal].question
      question = context[:journal].question

      if question.assigned_to
        html = assigned_question_html(question)
      else
        html = unassigned_question_html(question)
      end

      className = question.opened ? 'question' : 'question-closed'
      o += <<JS
<script type='text/javascript'>
   $('#change-#{context[:journal].id}').addClass('#{className}');
   $('#change-#{context[:journal].id} h4 .journal-link').after(' #{html} ');
</script>
JS
    end
    return o
  end

  def view_issues_edit_notes_bottom(context = { })
    f      = context[:form]
    @issue = context[:issue]
    o      = ''

    if @issue.pending_question?(User.current) && Setting.plugin_question_plugin[:close_all_questions] != "1"
      questions = @issue.pending_questions(User.current)
      o << content_tag(:p,
                    "<label>#{l(:field_question_to_answer)}</label> ".html_safe +
                    select_tag('question_to_answer', options_for_select([[]] + questions.collect {|q| [truncate(q.journal.notes, :length => Question::TruncateTo), q.id]}))
                    )
    end
    o << content_tag(:p,
                     "<label>#{l(:field_question_assign_to)}</label> ".html_safe +
                     text_field_tag('note[question_assigned_to]', nil, :size => "40"))
    o << javascript_tag("observeAutocompleteField('note_question_assigned_to', '#{escape_javascript questions_autocomplete_for_user_login_path(@issue.project, @issue)}')")

    return o
  end

  def controller_issues_edit_before_save(context = { })
    params  = context[:params]
    journal = context[:journal]
    issue   = context[:issue]
    if params[:note] && !params[:note][:question_assigned_to].blank?
      unless journal.question # Update handled by Journal hooks
                              # New
        journal.question = Question.new(
            :author => User.current,
            :issue  => journal.issue
        )
        if params[:note][:question_assigned_to].downcase != 'anyone'
          # Assigned to a specific user
          assign_question_to_user(journal, User.find_by_login(params[:note][:question_assigned_to]))
        end
      end
    end

    if Setting.plugin_question_plugin[:close_all_questions] == "1"
      # Close any open questions
      if journal.issue.present? && journal.issue.pending_question?(journal.user)
        journal.issue.close_pending_questions(journal.user, journal)
      end
    else
      # Close specific question
      if params[:question_to_answer] and !params[:question_to_answer].empty?
        question = Question.find(params[:question_to_answer])
        question.close!(journal)
      end
    end

    return ''
  end

  def view_issues_sidebar_issues_bottom(context = { })
    project = context[:project]
    if project
      question_count = Question.count_of_open_for_user_on_project(User.current, project)
    else
      question_count = Question.count_of_open_for_user(User.current)
    end

    if question_count > 0
      return link_to(l(:text_questions_for_me) + " (#{question_count})",
                     {
                         :controller => 'issuequestions',
                         :action     => 'my_issue_filter',
                         :project    => project,
                         :only_path  => true
                     },
                     { :class => 'question-link' }
      ) + '<br />'.html_safe
    else
      return ''
    end

  end

  private

  def assign_question_to_user(journal, user)
    journal.question.assigned_to = user
  end
end
