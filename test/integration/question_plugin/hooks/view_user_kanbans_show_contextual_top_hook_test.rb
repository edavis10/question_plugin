require File.dirname(__FILE__) + '/../../../test_helper'

class QuestionPlugin::Hooks::ViewUserKanbansShowContextualTopTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  begin
    require 'kanban'

    context "#view_user_kanbans_show_contextual_top" do
      setup do
        IssueStatus.generate!(:is_default => true)
        @user = User.generate!(:login => 'test', :password => 'test', :password_confirmation => 'test')
        @project = Project.generate!.reload
        User.add_to_project(@user, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues]))
        login_as('test', 'test')

        @issue1 = Issue.generate_for_project!(@project).reload
        
      end

      context "for a user without questions" do
        should "not render a question link" do
          visit '/kanban/my-requests'
          
          assert_select "a.question-link", :count => 0
        end
      end

      context "for a user with questions" do
        should "render a question link" do
          journal = Journal.generate!(:notes => 'Test question', :issue => @issue1)
          Question.generate!(:journal => journal, :assigned_to => @user)
          assert_equal 1, Question.count_of_open_for_user(@user)
          
          visit '/kanban/my-requests'
          
          assert_select "a.question-link"
        end
        
      end
      
    end

  rescue LoadError
    puts 'skipping redmine_kanban tests'
  end
end

