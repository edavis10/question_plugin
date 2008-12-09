class QuestionsController < ApplicationController
  unloadable
  layout 'base'
  
  # Create a query in the session and redirects to the issue list with that query
  def my_issue_filter
    @project = Project.find(params[:project]) unless params[:project].nil?
    
    @query = Query.new(:name => "_")
    @query.project = @project unless params[:project].nil?
    @query.add_filter("question_assigned_to_id", '=',['me'])

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
    redirect_to :controller => 'issues', :action => 'index', :project_id => params[:project]
  end
end
