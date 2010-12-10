require 'test_helper'

class MyPageBlocksTest < ActionController::IntegrationTest
  def setup
    @me = User.generate_with_protected!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    @project = Project.generate!
    User.add_to_project(@me, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues, :add_issue_notes, :edit_issues]))
    @issue = Issue.generate_for_project!(@project)
    @question_journal = Journal.generate!(:issue => @issue, :user => @me)
    @question = Question.generate!(:issue => @issue, :journal => @question_journal, :author => @me, :assigned_to => @me)
  end
  
  context "Questions asked by me" do
    setup do
      login_as
      click_link "My page"
      assert_response :success
    end
    
    should "add a new block" do
      click_link "Personalize this page"
      assert_response :success

      select "Questions asked by me", :from => 'block-select'
      # TODO: Ajax form that only allows XHR, cannot submit
      # submit_form "block-form"
    end
    
    should "list all open questions asked by me" do
      # Add block by hand
      my_layout = @me.pref[:my_page_layout] || {}
      my_layout['top'] ||= []
      my_layout['top'].unshift 'questions_asked_by_me'
      @me.pref[:my_page_layout] = my_layout
      assert @me.pref.save
      
      click_link "My page"
      assert_response :success

      assert_select 'h3', :text => "Questions asked by me (1)"
      assert_select 'table.list' do
        assert_select 'td.question-content', :count => 1
      end
    end
    
  end
  

  context "Questions for me" do
    setup do
      login_as
      click_link "My page"
      assert_response :success
    end
    
    should "add a new block" do
      click_link "Personalize this page"
      assert_response :success

      select "Questions for me", :from => 'block-select'
      # TODO: Ajax form that only allows XHR, cannot submit
      # submit_form "block-form"
    end
    
    should "list all open questions assigned to me" do
      # Add block by hand
      my_layout = @me.pref[:my_page_layout] || {}
      my_layout['top'] ||= []
      my_layout['top'].unshift 'questions_for_me'
      @me.pref[:my_page_layout] = my_layout
      assert @me.pref.save
      
      click_link "My page"
      assert_response :success

      assert_select 'h3', :text => "Questions for me (1)"
      assert_select 'table.list' do
        assert_select 'td.question-content', :count => 1
      end
    end
    
  end
  
end
