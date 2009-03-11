require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionsController, "#my_issue_filter" do
  it 'should search for the project' do
    tracker = mock_model(Tracker, :name => 'test')
    project_descendants = mock('project_descendants')
    project_descendants.stub!(:active).and_return([])
    project = mock_model(Project,
                         :id => 2,
                         :rolled_up_trackers => [tracker],
                         :users => [],
                         :issue_categories => [],
                         :versions => [],
                         :active_children => [],
                         :all_issue_custom_fields => [],
                         :descendants => project_descendants
                         )
    Project.should_receive(:find).with('2').and_return(project)
    get :my_issue_filter, :project => project.id
  end

  it 'should create a new Query object with the Question set to the current user' do
    get :my_issue_filter
    assigns[:query].filters.should have_key('question_assigned_to_id')
    filter = assigns[:query].filters['question_assigned_to_id']
    filter[:values].should eql(["me"])
    filter[:operator].should eql("=")
  end

  it 'should create a new Query object for all Issue statuses' do
    get :my_issue_filter
    assigns[:query].filters.should have_key('status_id')
    assigns[:query].filters['status_id'][:operator].should eql("*")
  end

  it 'should save the Query object into the session' do
    get :my_issue_filter
    session[:query].should have_key(:filters)
    session[:query][:filters].should have_key('question_assigned_to_id')
  end

  it 'should redirect to the issue list' do
    get :my_issue_filter
    response.should be_redirect
    response.should redirect_to(:controller => 'issues', :action => 'index', :project_id => nil)
  end
end
