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
                         :shared_versions => [],
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

describe QuestionsController, '#autocomplete_for_user_login' do
  integrate_views
  def do_request(params={:user => 'test'})
    post :autocomplete_for_user_login, params
  end

  it 'should be successful with no user parameter' do
    do_request(:user => nil)
    response.should be_success
  end
  
  it 'should find all users who match the parameters' do
    User.should_receive(:all).with({
                                     :conditions =>
                                     ["LOWER(login) LIKE :user OR LOWER(firstname) LIKE :user OR LOWER(lastname) LIKE :user", {:user => 'test%'}],
                                     :limit => 10,
                                     :order => 'login ASC'
                                   }).and_return([])
    do_request
  end

  it 'should only check active users' do
    User.should_receive(:active).and_return(User)
    User.stub!(:all).and_return([])
    do_request
  end

  it 'should be successful' do
    do_request
    response.should be_success
  end

  it 'should render the autocomplete_for_user_login template' do
    do_request
    response.should render_template('autocomplete_for_user_login')
  end

  describe 'with an issue_id' do
    before(:each) do
      @author = mock_model(User, :login => 'author', :name => "Issue author")
      @assigned_user = mock_model(User, :login => 'assignee', :name => "Issue assignee")
      @issue = mock_model(Issue)
      @issue.stub!(:author).and_return(@author)
      @issue.stub!(:assigned_to).and_return(@assigned_user)
      Issue.stub!(:find_by_id).and_return(@issue)
    end
    
    it 'should find the issue' do
      Issue.should_receive(:find_by_id).with("100").and_return(@issue)
      do_request(:issue_id => "100")
    end

    it 'should display the issue author in the user list' do
      do_request(:issue_id => "100")

      response.should have_tag("ul") do
        with_tag("li", /author/)
      end
    end

    it 'should display the user who is assigned the issue in the user list' do
      do_request(:issue_id => "100")

      response.should have_tag("ul") do
        with_tag("li", /assignee/)
      end
    end
  end
  
  describe 'template' do
    it 'should list all the matching users' do
      users = [
               mock_model(User, :login => 'test1', :name => 'Test user'),
               mock_model(User, :login => 'test2', :name => 'Test user 2'),
              ]

      User.should_receive(:all).and_return(users)
      do_request
      response.should have_tag("ul") do
        with_tag("li",/test1/)
        with_tag("li",/test2/)
      end

    end

    it 'should include "Anyone"' do
      do_request
      response.should have_tag("ul") do
        with_tag("li","Anyone")
      end
    end
  end
end
