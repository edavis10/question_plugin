class QuestionJournalHooks < Redmine::Hook::ViewListener
  # Have to inclue Gravatars because ApplicationHelper will not get it
  include GravatarHelper::PublicMethods

  def view_journals_notes_form_after_notes(context = { })
    @journal = context[:journal]
    if @journal.question && @journal.question.opened
      # Allow the Remove option and no blank option
      options = [[l(:text_question_remove), :remove]] + [[l(:text_anyone), :anyone]] + (@journal.issue.assignable_users.collect {|m| [m.name, m.id]})
      selected = @journal.question.assigned_to.id
      blank = false
    else
      # No Remove option but a blank option
      options = [[l(:text_anyone), :anyone]] + (@journal.issue.assignable_users.collect {|m| [m.name, m.id]})
      selected = nil
      blank = true
    end
    
    
    
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label> " + 
                     select(:question,
                            :assigned_to_id,
                            options,
                            :selected => selected,
                            :include_blank => blank ))
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
      
        # TODO: Duplicated in question_issue_hooks.rb
        if question.assigned_to
          html = "<span class=\"question-line\">"
          html << "  <a name=\"question-#{h(question.id)}\" href=\"#question-#{h(question.id)}\">"
          html << "#{l(:text_question_for)} #{question.assigned_to.to_s}"
          html << "  </a>"
          html << "<span>#{gravatar(question.assigned_to.mail, { :size => 16, :class => '' })}</span> </span>"
        else
          html = "<span class=\"question-line\">"
          html << "  <a name=\"question-#{h(question.id)}\" href=\"#question-#{h(question.id)}\">"
          html << l(:text_question_for_anyone)
          html << "  </a>"
          html << "</span>"
        end

        page << "$('change-#{@journal.id}').addClassName('question');"
        page << "$$('#change-#{@journal.id} h4 div span.question-line').each(function(ele) {ele.remove()});"
        page << "$$('#change-#{@journal.id} h4 div').each(function(ele) { ele.insert({ top: ' #{html} ' }) });"
      
      elsif @journal && @journal.question.nil?
        # No question found, make sure the UI reflects this
        page << "$('change-#{@journal.id}').removeClassName('question');"
        page << "$$('#change-#{@journal.id} h4 div span.question-line').each(function(ele) {ele.remove()});"
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
    journal.question.save!
    journal.save
  end
end
