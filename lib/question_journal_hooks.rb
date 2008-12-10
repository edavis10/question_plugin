class QuestionJournalHooks < Redmine::Hook::ViewListener
  
  def view_journals_notes_form_after_notes(context = { })
    @journal = context[:journal]
    if @journal.question && @journal.question.opened
      selected = @journal.question.assigned_to.id
    else
      selected = nil
    end
    
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label>" + 
                     select(:question,
                            :assigned_to_id,
                            [[l(:text_anyone), :anyone]] + (@journal.issue.assignable_users.collect {|m| [m.name, m.id]}),
                            :include_blank => true,
                            :selected => selected))
    return o
  end
  
  def controller_journals_edit_post(context = { })
    journal = context[:journal]
    params = context[:params]

    if params[:question] && !params[:question][:assigned_to_id].blank?

      if journal.question && journal.question.opened
        journal.question.update_attributes(:assigned_to_id => params[:question][:assigned_to_id])
      else
        if journal.question && !journal.question.opened
          # Existing closed question. Delete it first
          journal.question.destroy
        end
        # TODO: Duplicated in question_issue_hook
        journal.question = Question.new(
                                        :author => User.current,
                                        :issue => journal.issue
                                        )
        if params[:question][:assigned_to_id] != 'anyone'
          # Assigned to a specific user
          journal.question.assigned_to = User.find(params[:question][:assigned_to_id].to_i)
        end
        
        journal.save
      end
    end
    
    return ''
  end
end
