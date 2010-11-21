require File.dirname(__FILE__) + '/../test_helper'

class QuestionsControllerTest < ActionController::TestCase
  context "#my_issue_filter" do
    setup do
      @project = Project.generate!
    end
    
    should 'search for the project' do
      get :my_issue_filter, :project => @project.id
    end

    should 'create a new Query object with the Question set to the current user' do
      get :my_issue_filter
      assert assigns['query'].filters['question_assigned_to_id']
      filter = assigns['query'].filters['question_assigned_to_id']
      assert_equal ["me"], filter[:values]
      assert_equal "=", filter[:operator]
    end

    should 'create a new Query object for all Issue statuses' do
      get :my_issue_filter
      assert assigns['query'].filters['status_id']
      assert_equal "*", assigns['query'].filters['status_id'][:operator]
    end

    should 'save the Query object into the session' do
      get :my_issue_filter
      assert session[:query][:filters]
      assert session[:query][:filters]['question_assigned_to_id']
    end

    should 'redirect to the issue list' do
      get :my_issue_filter
      assert_response :redirect
      assert_redirected_to :controller => 'issues', :action => 'index', :project_id => nil
    end
  end
  
  context '#autocomplete_for_user_login' do
    should 'be successful with no user parameter' do
      post :autocomplete_for_user_login, :user => nil
      assert_response :success
    end
    
    should 'find all users who match the parameters' do
      @test_user = User.generate_with_protected!(:login => 'test-user')
      @test_person = User.generate_with_protected!(:login => 'test-person')
      @mr_test = User.generate_with_protected!(:firstname => 'Mr', :lastname => 'Test')
      @test_bond = User.generate_with_protected!(:firstname => 'Test', :lastname => 'Bond')
      @no_match =  User.generate_with_protected!(:firstname => 'No', :lastname => 'Match')
      
      post :autocomplete_for_user_login, :user => 'test'

      assert assigns['users'].include?(@test_user)
      assert assigns['users'].include?(@test_person)
      assert assigns['users'].include?(@mr_test)
      assert assigns['users'].include?(@test_bond)
      assert !assigns['users'].include?(@no_match)
    end

    should 'only check active users' do
      @test_user = User.generate_with_protected!(:login => 'test-user')
      @test_person = User.generate_with_protected!(:login => 'test-person', :status => User::STATUS_LOCKED)
      
      post :autocomplete_for_user_login, :user => 'test'

      assert assigns['users'].include?(@test_user)
      assert !assigns['users'].include?(@test_person)
    end

    should 'be successful' do
      post :autocomplete_for_user_login, :user => 'test'
      assert_response :success
    end

    should 'render the autocomplete_for_user_login template' do
      post :autocomplete_for_user_login, :user => 'test'
      assert_template 'autocomplete_for_user_login'
    end

    context 'with an issue_id' do
      setup do
        @author = User.generate_with_protected!(:login => 'test', :firstname => "Issue", :lastname => "author")
        @assigned_user = User.generate_with_protected!(:login => 'test-user', :firstname => "Issue", :lastname => "assignee")
        @project = Project.generate!
        @issue = Issue.generate_for_project!(@project, :author => @author, :assigned_to => @assigned_user)
      end
      
      should 'find the issue' do
        post :autocomplete_for_user_login, :user => 'test', :issue_id => @issue.id
        assert_equal @issue, assigns['issue']
      end

      should 'display the issue author in the user list' do
        post :autocomplete_for_user_login, :user => 'test', :issue_id => @issue.id

        assert_select "ul" do
          assert_select "li", /#{@author.lastname}/
        end
      end

      should 'display the user who is assigned the issue in the user list' do
        post :autocomplete_for_user_login, :user => 'test', :issue_id => @issue.id

        assert_select "ul" do
          assert_select "li", /#{@assigned_user.lastname}/
        end
      end
    end
    
    context 'template' do
      should 'list all the matching users' do
        @test_user = User.generate_with_protected!(:login => 'test-user')
        @test_person = User.generate_with_protected!(:login => 'test-person')

        post :autocomplete_for_user_login, :user => 'test'

        assert_select "ul" do
          assert_select "li", /test-user/
          assert_select "li", /test-person/
        end
        
      end

      should 'include "Anyone"' do
        post :autocomplete_for_user_login, :user => 'test'

        assert_select "ul" do
          assert_select "li", /Anyone/i
        end
      end
    end
  end
end
