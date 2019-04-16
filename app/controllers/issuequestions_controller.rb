class IssuequestionsController < ApplicationController
  unloadable
  layout 'base'
  
  # Create a query in the session and redirects to the issue list with that query
  def my_issue_filter
    new_filter_for_questions_assigned_to('me')
    redirect_to :controller => 'issues', :action => 'index', :project_id => params[:project]
  end

  def user_issue_filter
    new_filter_for_questions_assigned_to(params[:user_id])
    redirect_to :controller => 'issues', :action => 'index', :project_id => params[:project]
  end
  
  def hide
    @question = Question.find(params[:id])
    @question.hidden = true
    if @question.save
      redirect_to :back
    end
    
  end

  def autocomplete_for_user_login
    if params[:issue_id] && Setting.plugin_question_plugin[:only_members] == 1
      @issue = Issue.find(params[:issue_id])
      base = @issue.project.users
    else
      base = User
    end
    q = (params[:q] || params[:term] || params[:user]).to_s.strip.downcase
    if q.present?
      @users = base.active.where(["LOWER(login) LIKE :user OR LOWER(firstname) LIKE :user OR LOWER(lastname) LIKE :user", {:user => q + "%" }]).
                           limit(10).
                           order('login ASC')
    end
    @users ||=[]

    render :layout => false
  end

  private

  def new_filter_for_questions_assigned_to(user_id)
    @project = Project.find(params[:project]) unless params[:project].nil?
    
    @query = (ActiveSupport::Dependencies::search_for_file('issue_query') ? IssueQuery : Query).new(:name => "_",
                       :filters => {'status_id' => {:operator => '*', :values => [""]}}
                       )
    @query.project = @project unless params[:project].nil?
    @query.add_filter("question_assigned_to_id", '=',[user_id])

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
  end

end
