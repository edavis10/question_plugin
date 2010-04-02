class QuestionsController < ApplicationController
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

  def autocomplete_for_user_login
    if params[:user]
      @users = User.active.all(:conditions => ["LOWER(login) LIKE :user OR LOWER(firstname) LIKE :user OR LOWER(lastname) LIKE :user", {:user => params[:user]+"%" }],
                               :limit => 10,
                               :order => 'login ASC')
    end
    @users ||=[]

    if params[:issue_id]
      @issue = Issue.find_by_id(params[:issue_id])
    end
    render :layout => false
  end

  private

  def new_filter_for_questions_assigned_to(user_id)
    @project = Project.find(params[:project]) unless params[:project].nil?
    
    @query = Query.new(:name => "_",
                       :filters => {'status_id' => {:operator => '*', :values => [""]}}
                       )
    @query.project = @project unless params[:project].nil?
    @query.add_filter("question_assigned_to_id", '=',[user_id])

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
  end

end
