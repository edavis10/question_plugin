require File.dirname(__FILE__) + '/../../../test_helper'

require 'digest/md5'

class QuestionIssueHooksTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  def setup
    Setting.gravatar_enabled = '1'
    @user1 = User.generate!(:firstname => 'Test', :lastname => 'one', :login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    @user2 = User.generate!(:firstname => 'Test', :lastname => 'two')
    @project = Project.generate!.reload
    @issue = Issue.generate_for_project!(@project)
    @journal = Journal.generate!(:issue => @issue)
    User.add_to_project(@user1, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues]))
  end
  
  context 'view_issues_edit_notes_bottom' do
    context 'should render a text field' do
      setup do
        login_as
        visit_issue_page(@issue)
      end
      
      should 'with the selected users login' do
        assert_select 'input#note_question_assigned_to'
      end

      should 'with an area for the autocomplete choices' do
        assert_select 'div#note_question_assigned_to_choices'
      end

      should 'with the autocomplete JavaScript' do
        assert_select "script", :text => /Autocompleter/
      end

    end
  end

  context 'controller_issues_edit_before_save' do
    def call_hook(context)
      return QuestionIssueHooks.instance.controller_issues_edit_before_save( context )
    end
    
    setup do
      login_as
      visit_issue_page(@issue)

      fill_in "notes", :with => "Journal notes"
    end
    
    should 'should do nothing when no question is asked' do

      assert_difference("Journal.count") do
        assert_no_difference("Question.count") do
          click_button "Submit"

          assert_response :success
          assert_equal "/issues/#{@issue.id}", current_path
        end
      end
      
    end

    should 'should create a new question for the journal when a question was asked' do\
      fill_in "note_question_assigned_to", :with => @user2.reload.login

      assert_difference("Journal.count") do
        assert_difference("Question.count") do
          click_button "Submit"
          
          assert_response :success
          assert_equal "/issues/#{@issue.id}", current_path
        end
      end

      question = Question.last
      assert_equal @user2, question.assigned_to
    end  
    
    should 'should create a new question with no assigned_to user if the parameter is anyone' do
      fill_in "note_question_assigned_to", :with => 'anyone'

      assert_difference("Journal.count") do
        assert_difference("Question.count") do
          click_button "Submit"
          
          assert_response :success
          assert_equal "/issues/#{@issue.id}", current_path
        end
      end

      question = Question.last
      assert_equal nil, question.assigned_to
    end
  end

  context 'view_issues_history_journal_bottom with a journal and question' do
    setup do
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @journal = Journal.generate!(:issue => @issue)
      User.add_to_project(@user1, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues]))

      @question = Question.generate!(:assigned_to => @user1, :opened => true, :journal => @journal)
      
      login_as
      visit_issue_page(@issue)
    end
    
    should 'should use JavaScript' do
      assert_select 'script[type=?]', 'text/javascript'
    end

    should 'should add a CSS class' do
      assert_select 'script', :text => Regexp.new(Regexp.quote("addClassName('question')"))
    end

    should 'should display the users gravatar' do
      user_digest = Digest::MD5.hexdigest(@user1.mail)

      assert response.body.match(/#{user_digest}/)
    end
    
    should 'should insert a string into the h4>div' do
      assert_select 'h4 div'
    end
  end

  context 'view_issues_history_journal_bottom with a journal and no question' do
    setup do
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @journal = Journal.generate!(:issue => @issue)
      User.add_to_project(@user1, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues]))

      login_as
      visit_issue_page(@issue)
    end
    
    should 'should use not render anything' do
      assert_select 'script', :text => Regexp.new(Regexp.quote("addClassName('question')")), :count => 0
    end

  end

  context 'view_issues_sidebar_issues_bottom with a project' do
    context 'with questions' do
      setup do
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user1, :author => @user2)

        login_as
        visit '/projects'
        click_link @project.name
        assert_response :success
        click_link 'Issues'
        assert_response :success
      end

      should 'should return a link to my_issue_filter' do
        assert response.body.match(/questions\/my_issue_filter/)
      end
      
      should 'should display the number of questions in the link body' do
        assert_select 'a.question-link', :text => /1/
      end
    end
    
    context 'without questions' do
      setup do
        login_as
        visit '/projects'
        click_link @project.name
        assert_response :success
        click_link 'Issues'
        assert_response :success
      end
      
      should 'should not return anything' do
        assert_select 'a.question-link', :count => 0
      end
    end
  end

  context 'view_issues_sidebar_issues_bottom without a project' do
    context 'with questions' do
      setup do
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user1, :author => @user2)
        login_as
        visit '/issues'
      end

      should 'should return a link to my_issue_filter' do
        assert_select 'a[href=?]', '/questions/my_issue_filter'
      end
      
      should 'should display the number of questions in the link body' do
        assert_select 'a.question-link', :text => /1/
      end
    end
    
    context 'without questions' do
      should 'should not return anything' do
        login_as
        visit '/issues'

        assert_select 'a.question-link', :count => 0
      end
    end
  end


end
