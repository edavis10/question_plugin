class QuestionJournalHooks < Redmine::Hook::ViewListener
  # Have to inclue Gravatars because ApplicationHelper will not get it
  include GravatarHelper::PublicMethods

  def view_journals_notes_form_after_notes(context = { })
    @journal = context[:journal]
    if @journal.question && @journal.question.opened
      selected = @journal.question.assigned_to.id
    else
      selected = nil
    end
    
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label> " + 
                     select(:question,
                            :assigned_to_id,
                            [[l(:text_question_remove), :remove]] + [[l(:text_anyone), :anyone]] + (@journal.issue.assignable_users.collect {|m| [m.name, m.id]}),
                            :selected => selected))
    return o
  end
  
  def controller_journals_edit_post(context = { })
    journal = context[:journal]
    params = context[:params]

    if params[:question] && !params[:question][:assigned_to_id].blank?

      if journal.question && params[:question][:assigned_to_id] == 'remove'
        # Wants to remove the question
        journal.question.destroy
      elsif journal.question && journal.question.opened
        # Reassignment
        journal.question.update_attributes(:assigned_to_id => params[:question][:assigned_to_id])
      elsif journal.question && !journal.question.opened
        # Existing question, destry it first and then add a new question
        journal.question.destroy
        add_new_question(journal, params[:question][:assigned_to_id])
      else
        add_new_question(journal, params[:question][:assigned_to_id])
      end

    end
    
    return ''
  end
  
  def view_journals_update_rjs_bottom(context = { })
    @journal = context[:journal]
    page = context[:page]
    unless @journal.frozen?
      @journal.reload
      if @journal && @journal.question && @journal.question.opened?
        question = @journal.question
      
        if question.assigned_to
          html = "<span class=\"question-line\">#{l(:text_question_for)} #{question.assigned_to.to_s} <span>#{gravatar(question.assigned_to.mail, { :size => 16, :class => '' })}</span> </span>"
        else
          html = "<span class=\"question-line\">" + l(:text_question_for_anyone) + "</span>"
        end
        
        page << "$('change-#{@journal.id}').addClassName('question');"
        page << "$$('#change-#{@journal.id} h4 div span.question-line').each(function(ele) {ele.remove()});"
        page << "$$('#change-#{@journal.id} h4 div').each(function(ele) { ele.insert({ top: ' #{html} ' }) });"
      
      end
    end
    return ''
  end
  
  private
  
  def add_new_question(journal, assigned_to)
    # TODO: Duplicated in question_issue_hook
    journal.question = Question.new(
                                    :author => User.current,
                                    :issue => journal.issue
                                    )
    if assigned_to != 'anyone'
      # Assigned to a specific user
      journal.question.assigned_to = User.find(assigned_to.to_i)
    end
        
    journal.save
  end
end
