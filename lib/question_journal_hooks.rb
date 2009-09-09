class QuestionJournalHooks < QuestionHooksBase
  def view_journals_notes_form_after_notes(context = { })
    @journal = context[:journal]
    if @journal.question && @journal.question.opened && @journal.question.assigned_to
      assigned_to = @journal.question.assigned_to.login
    else
      assigned_to = ''
    end
    
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label> " +
                     text_field_tag('question[assigned_to]', assigned_to, :size => "40"))

    o << content_tag(:div,'', :id => "question_assigned_to_choices", :class => "autocomplete")
    o << javascript_tag("new Ajax.Autocompleter('question_assigned_to', 'question_assigned_to_choices', '#{ url_for(:controller => 'questions', :action => 'autocomplete_for_user_login', :id => @journal.project, :issue_id => @journal.issue) }', { minChars: 1, frequency: 0.5, paramName: 'user', select: 'field' });")

    return o
  end
  
  def controller_journals_edit_post(context = { })
    journal = context[:journal]
    params = context[:params]

    if params[:question] && params[:question][:assigned_to]

      if journal.question && params[:question][:assigned_to].blank?
        # Wants to remove the question
        journal.question.destroy
      elsif journal.question && journal.question.opened
        # Reassignment
        if params[:question][:assigned_to].downcase == 'anyone'
          journal.question.update_attributes(:assigned_to => nil)
        else
          journal.question.update_attributes(:assigned_to => User.find_by_login(params[:question][:assigned_to]))
        end
      elsif journal.question && !journal.question.opened
        # Existing question, destry it first and then add a new question
        journal.question.destroy
        add_new_question(journal, User.find_by_login(params[:question][:assigned_to]))
      else
        if params[:question][:assigned_to].downcase == 'anyone'
          add_new_question(journal)
        elsif !params[:question][:assigned_to].blank?
          add_new_question(journal, User.find_by_login(params[:question][:assigned_to]))
        else
          # No question
        end
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
          html = assigned_question_html(question)
        else
          html = unassigned_question_html(question)
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
  
  def add_new_question(journal, assigned_to=nil)
    journal.question = Question.new(
                                    :author => User.current,
                                    :issue => journal.issue,
                                    :assigned_to => assigned_to
                                    )
    journal.question.save!
    journal.save
  end
end
