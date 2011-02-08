require File.dirname(__FILE__) + '/../../../test_helper'

class QuestionJournalHooksTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  def setup
    Setting.gravatar_enabled = '1'
    @user1 = User.generate!(:firstname => 'Test', :lastname => 'one', :login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    @user2 = User.generate!(:firstname => 'Test', :lastname => 'two')
    @project = Project.generate!.reload
    @issue = Issue.generate_for_project!(@project)
    @journal = Journal.generate!(:issue => @issue, :notes => 'A note')
    User.add_to_project(@user1, @project, Role.generate!(:permissions => [:view_issues, :add_issues, :edit_issues, :edit_issue_notes]))
  end
  
  context '#views_journals_notes_form_after_notes' do
    context 'should render a text field' do
      setup do
        login_as
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user2, :opened => true)
        visit "/journals/edit/#{@journal.id}" # RJS
      end

      should 'with the selected users login' do
        assert response.body.match(/#{@user2.reload.login}/)
      end

      should 'with an area for the autocomplete choices' do
        assert response.body.match 'question_assigned_to_choices'
      end

      should 'with the autocomplete JavaScript' do
        assert response.body.match(/Autocompleter/)
      end
    end
  end


  context '#controller_journals_edit_post' do
    setup do
      login_as
    end
    
    context 'with an empty question' do
      should 'should do nothing' do

        assert_no_difference('Journal.count') do
          assert_no_difference('Question.count') do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => 'New notes'
          end
        end
        
      end
    end

    context 'with a new question for anyone' do
      setup do
        assert_no_difference('Journal.count') do
          assert_difference('Question.count') do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => 'New notes', :question => { :assigned_to => 'anyone'}
          end
        end
      end
      
      should 'should create a new question' do
        question = Question.last
        assert_equal nil, question.assigned_to
      end

      should 'should add the CSS class of "question" to the journal div' do
        assert response.body.match(/addClassName\('question'\)/)
      end

      should 'should remove all existing question lines using RJS' do
        assert response.body.match(/question-line.*remove/)
      end

      should 'should add the generated HTML to the top of the side div' do
        assert response.body.match(/insert.*top/)
      end
    end

    context 'with a new question for a user' do
      should 'should create a new question' do
        assert_no_difference('Journal.count') do
          assert_difference('Question.count') do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => 'New notes', :question => { :assigned_to => @user2.reload.login}
          end
        end

        question = Question.last
        assert_equal @user2, question.assigned_to
      end
    end

    context 'with a reassigned question' do
      should 'should change the assignment of the question' do
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user2, :opened => true)
        
        assert_no_difference('Journal.count') do
          assert_no_difference('Question.count') do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => 'New notes', :question => { :assigned_to => @user1.reload.login}
          end
        end

        question = Question.last
        assert_equal @user1, question.assigned_to
      end
    end

    context 'with a removed question' do
      setup do
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user2, :opened => true)
        
        assert_no_difference('Journal.count') do
          assert_difference('Question.count', -1) do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => 'New notes', :question => { :assigned_to => ''}
          end
        end
      end
      
      should 'should destroy the question' do
        assert_equal nil, Question.find_by_id(@question.id)
      end

      should 'should remove the CSS class of "question" from the journal div' do
        assert response.body.match(/removeClassName\('question'\)/)
      end

      should 'should remove all existing question lines using RJS' do
        assert response.body.match(/question-line.*remove/)
      end

    end

    context 'with a removed journal by clearing the notes' do
      setup do
        @question = Question.generate!(:issue => @issue, :journal => @journal, :assigned_to => @user2, :opened => true)
        
        assert_difference('Journal.count',-1) do
          assert_difference('Question.count', -1) do
            post "/journals/edit/#{@journal.id}", :format => 'js', :notes => '', :question => { :assigned_to => ''}
            assert_response :success
          end
        end
      end
      
      should 'should destroy the question' do
        assert_equal nil, Question.find_by_id(@question.id)
      end
    end

  end

end
