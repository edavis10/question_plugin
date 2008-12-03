class QuestionIssueHooks < Redmine::Hook::ViewListener
  def view_issues_edit_notes_bottom(context = { })
    f = context[:form]
    @issue = context[:issue]
    return content_tag(:p, select(:note, :question_assigned_to, (@issue.assignable_users.collect {|m| [m.name, m.id]}), :include_blank => true))

  end
  
  def controller_issues_edit_before_save(context = { })
    params = context[:params]
    journal = context[:journal]
    if params[:note][:question_assigned_to]
      user = params[:note][:question_assigned_to].to_i
      if journal.question
        # Update
        # TODO:
      else
        # New
        journal.question = Question.new(
                                        :author => User.current,
                                        :assigned_to => User.find(user),
                                        :issue => journal.issue
                                        )
      end
    end
    
    return ''
  end
end
