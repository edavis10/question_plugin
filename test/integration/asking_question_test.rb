require 'test_helper'

class AskingQuestionTest < ActionController::IntegrationTest
  context "asking a question" do
    should "deliver a question email" do
      ActionMailer::Base.deliveries.clear

      @author = User.generate_with_protected!
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)

      @issue.journal_notes = "Question"
      @issue.extra_journal_attributes = {
        :question => Question.new(:assigned_to => @author, :author => @author, :issue => @issue)
      }

      assert_difference("Question.count") do
        assert @issue.save
      end


      assert_sent_email do |email|
        email.subject =~ /Question/i
      end
      
    end
    
  end
end

