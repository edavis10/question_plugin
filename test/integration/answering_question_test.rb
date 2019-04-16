require 'test_helper'

class AnsweringQuestionTest < ActionController::IntegrationTest
  context "answering a question" do
    setup do

      @author = User.generate_with_protected!
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @question = Question.new(:assigned_to => @author, :author => @author, :issue => @issue)
      @issue.journal_notes = "Question"
      
      @issue.question = @question
      assert @issue.save
      ActionMailer::Base.deliveries.clear
    end
    
    should "close all pending questions for the answerer" do
      @issue.journal_notes = "Answer"
      @issue.journal_user = @author
      assert @issue.save

      @question.reload

      assert !@question.opened, "Answered question not closed"
    end
    
    
    should "deliver an answer email" do
      @issue.journal_notes = "Answer"
      @issue.journal_user = @author
      assert @issue.save
      
      assert_sent_email do |email|
        email.subject =~ /Answer/i
      end
      
    end
    
  end
end

