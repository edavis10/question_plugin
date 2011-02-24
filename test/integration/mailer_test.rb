require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  def setup
    ActionMailer::Base.deliveries.clear
    @asker = User.generate_with_protected!(:mail_notification => 'all')
    @responder = User.generate_with_protected!(:mail_notification => 'all')
    @project = Project.generate!
    @role = Role.generate!(:permissions => [:view_issues, :add_issue_notes, :edit_issues])
    Member.generate!(:principal => @asker, :roles => [@role], :project => @project)
    Member.generate!(:principal => @responder, :roles => [@role], :project => @project)
    @issue = Issue.generate_for_project!(@project)
    @issue.add_watcher(@asker)
    @issue.add_watcher(@responder)
  end

  context "with no question for the recipient" do
    should "not render a question section" do
      Journal.create!(:journalized => @issue, :user => @asker)

      assert_equal 4, ActionMailer::Base.deliveries.length # Create and Edit for 2 users
      ActionMailer::Base.deliveries.each do |mail|
        assert !mail.body.include?("Question"), "Question found in the email body"
      end
      
    end
  end

  context "with a question asked to the recipient" do
    setup do
      @question = Question.new(:issue => @issue, :author => @asker, :assigned_to => @responder)
      @journal = Journal.new(:journalized => @issue , :user => @asker, :notes => 'Some notes')
      @journal.question = @question
      assert @journal.save!
    end
  
    should "render the question section" do
      assert_sent_email do |email|
        email.body =~ /question for/i
      end
    end

    should "add the Question-Asked mail header" do
      assert_sent_email do |email|
        email.header["x-redmine-question-asked"].present? &&
          email.header["x-redmine-question-asked"].to_s == @asker.login
      end
    end
    
    should "add the Question-Assigned-To mail header" do
      assert_sent_email do |email|
        email.header["x-redmine-question-assigned-to"].present? &&
          email.header["x-redmine-question-assigned-to"].to_s == @responder.login
      end
    end

  end

  context "with an answer for the recipient" do
    setup do
      @question = Question.new(:issue => @issue, :author => @asker, :assigned_to => @responder)
      @journal = Journal.new(:journalized => @issue , :user => @asker, :notes => 'Some notes')
      @journal.question = @question
      assert @journal.save!

      @answer = Journal.create!(:journalized => @issue, :user => @responder, :notes => 'An answer')
    end
  
    should "render the answer section" do
      assert_sent_email do |email|
        email.body =~ /Question Answered/i
      end
    end
    

    should "add the Question-Answer mail header" do
      assert_sent_email do |email|
        email.header["x-redmine-question-answer"].present? &&
          email.header["x-redmine-question-answer"].to_s == "#{@issue.id}-#{@answer.id}"
      end
    end
  end
  
end
