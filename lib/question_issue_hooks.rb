class QuestionIssueHooks < Redmine::Hook::ViewListener
  def view_issues_edit_notes_bottom(context = { })
    f = context[:form]
    @issue = context[:issue]
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label>" + 
                     select(:note,
                            :question_assigned_to,
                            [["Anyone", :anyone]] + (@issue.assignable_users.collect {|m| [m.name, m.id]}),
                            :include_blank => true))
    return o
  end
  
  def controller_issues_edit_before_save(context = { })
    params = context[:params]
    journal = context[:journal]
    unless params[:note][:question_assigned_to].blank?
      if journal.question
        # Update
        # TODO:
      else
        # New
        journal.question = Question.new(
                                        :author => User.current,
                                        :issue => journal.issue
                                        )
        if params[:note][:question_assigned_to] != 'anyone'
          # Assigned to a specific user
          journal.question.assigned_to = User.find(params[:note][:question_assigned_to].to_i)
        end
      end
    end
    
    return ''
  end
end
