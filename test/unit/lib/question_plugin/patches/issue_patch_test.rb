require File.dirname(__FILE__) + '/../../../../test_helper'

# TODO: rename under the namespace
class QuestionIssuePatchTest < ActionController::TestCase

  context "Issue" do
    subject {Issue.new}
    should_have_many :questions
    should_have_many :open_questions
  end

  context "#pending_question?" do
    setup do
      @user = User.generate!
      @project = Project.generate!
    end
    
    should 'return false if there are no open questions' do
      @issue = Issue.new
      assert_equal false, @issue.pending_question?(@user)
    end

    should 'return false if there are no open questions for the current user' do
      @other_user = User.generate!
      @issue = Issue.generate_for_project!(@project)
      @issue.journal_notes = "Test"
      assert @issue.save
      journal = @issue.journals.last

      question_one = Question.generate!(:assigned_to => @other_user, :issue => @issue, :journal => journal)
      
      assert_equal false, @issue.pending_question?(@user)
    end

    should 'return true if there is an open question for the current user' do
      @other_user = User.generate!
      @issue = Issue.generate_for_project!(@project)
      @issue.journal_notes = "Test"
      assert @issue.save
      journal = @issue.journals.last
      question_one = Question.generate!(:assigned_to => @other_user, :issue => @issue, :journal => journal)

      @issue.journal_notes = "Test 2"
      assert @issue.save
      journal = @issue.journals.last
      question_two = Question.generate!(:assigned_to => @user, :issue => @issue, :journal => journal)
      
      assert @issue.pending_question?(@user)
    end

    should 'return true if there is an open question for anyone' do
      @other_user = User.generate!
      @issue = Issue.generate_for_project!(@project)
      @issue.journal_notes = "Test"
      assert @issue.save
      journal = @issue.journals.last
      question_one = Question.generate!(:assigned_to => @other_user, :issue => @issue, :journal => journal)

      @issue.journal_notes = "Test 2"
      assert @issue.save
      journal = @issue.journals.last
      question_two = Question.generate!(:assigned_to => nil, :issue => @issue, :journal => journal)

      assert @issue.pending_question?(@user)
    end
  end

  context "#close_pending_questions" do
    setup do
      @user = User.generate!.reload
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @issue.journal_notes = "Test 2"
      @issue.journal_user = @user
      assert @issue.save
      @journal = @issue.journals.last
    end
    
    should 'close any open questions for user' do
      question = Question.generate!(:assigned_to => @user, :issue => @issue, :journal => @journal)
      assert question.opened?

      @issue.close_pending_questions(@user, @journal)
      assert !question.reload.opened?
    end
    
    should 'close any questions for anyone' do
      question = Question.generate!(:assigned_to => nil, :issue => @issue, :journal => @journal)
      assert question.opened?

      @issue.close_pending_questions(@user, @journal)
      assert !question.reload.opened?
    end

    should 'not close any questions for other users' do
      @other_user = User.generate!
      question = Question.generate!(:assigned_to => @other_user, :issue => @issue, :journal => @journal)
      assert question.opened?

      @issue.close_pending_questions(@user, @journal)
      assert question.opened?
    end

  end

end
