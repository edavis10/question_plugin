require File.dirname(__FILE__) + '/../test_helper'

class QuestionMailerTest < ActiveSupport::TestCase
  should 'be a subclass of Redmines Mailer' do
    assert QuestionMailer.ancestors.include?(Mailer)
  end

  context '#asked_question with a question' do
    setup do
      @user = User.generate!(:firstname => 'Test', :lastname => 'User', :mail => 'test@example.org')
      @author = User.generate!(:firstname => 'Author', :lastname => 'User', :mail => 'author@example.org')
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project, :subject => "Add new stuff")
      @question = Question.generate!(:assigned_to => @user, :author => @author, :issue => @issue)
      @journal = Journal.generate!(:details => [], :notes => "This is the question for the user", :question => @question)
      Setting.mail_from = "redmine@example.com"
      Setting.bcc_recipients = false
      @mail = QuestionMailer.create_asked_question(@journal)
    end
    
    should 'create a mail message' do
      assert_equal TMail::Mail, @mail.class
    end
    
    should 'have the subject prefixed with "Question"' do
      assert_match /Question/, @mail.subject
    end
    
    should 'use the issue subject for the subject line' do
      assert_match /add new stuff/i, @mail.subject
    end

    should 'use the issue id in the subject line' do
      assert_match /##{@issue.id}/, @mail.subject
    end

    should 'be sent to the assigned_to user' do
      assert @mail.to.include?(@user.mail)
    end
    
    should 'have a link to the issue' do
      assert_match /issues\/#{@issue.id}/, @mail.encoded
    end

    should 'have a question in the body' do
      assert_match /is the question for the user/, @mail.encoded
    end
    
    should "use the User's name in the from" do
      assert_match /From:.*#{@author.name}/, @mail.encoded
    end

    should "have (Redmine) in the from to show it came from Redmine" do
      assert_match /From:.*Redmine/, @mail.encoded
    end

    should "have the redmine system email address as the from" do
      assert_match /From:.*#{Setting.mail_from}/, @mail.encoded
    end

    should "have the X-Redmine-Question-Asked header" do
      assert_match /X-Redmine-Question-Asked.*#{@author.login}/, @mail.encoded
    end

    should "have the X-Redmine-Question-Assigned header" do
      assert_match /X-Redmine-Question-Assigned-To.*#{@user.login}/, @mail.encoded
    end

  end


  context '#asked_question with a question for anyone' do
    should 'not be sent to anyone' do
      @author = User.generate!(:firstname => 'Author', :lastname => 'User', :mail => 'author@example.org')
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project, :subject => "Add new stuff")

      @question = Question.generate!(:assigned_to => nil, :author => @author, :issue => @issue)
      @journal = Journal.generate!(:details => [], :notes => "This is the question for the user", :question => @question)
      
      @mail = QuestionMailer.create_asked_question(@journal)
      assert_nil @mail.to
      assert_nil @mail.cc
      assert_nil @mail.bcc
    end
  end

  context '#answered_question' do
    setup do
      @user = User.generate!(:firstname => 'Test', :lastname => 'User', :mail => 'test@example.org')
      @author = User.generate!(:firstname => 'Author', :lastname => 'User', :mail => 'author@example.org')
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project, :subject => "Add new stuff")

      @journal_with_question = Journal.generate!(:details => [], :notes => "This is the question for the user", :question => @question)
      @journal_with_answer = Journal.generate!(:details => [], :notes => "This is the answer for the user", :question => @question)

      @question = Question.generate!(:assigned_to => @user, :author => @author, :issue => @issue, :journal => @journal_with_question)
      Setting.mail_from = "redmine@example.com"
      Setting.bcc_recipients = false
      @mail = QuestionMailer.create_answered_question(@question, @journal_with_answer)
    end
    
    should 'create a mail message' do
      assert_equal TMail::Mail, @mail.class
    end

    should 'have the subject prefixed with "Answered"' do
      assert_match /Answered/, @mail.subject
    end

    should 'use the issue subject for the subject line' do
      assert_match /add new stuff/i, @mail.subject
    end

    should 'use the issue id in the subject line' do
      assert_match /##{@issue.id}/, @mail.subject
    end

    should 'be sent to the question author' do
      assert @mail.to.include?(@author.mail)
    end

    should 'have a link to the issue' do
      assert_match /issues\/#{@issue.id}/, @mail.encoded
    end

    should 'have the question in the body' do
      assert_match /is the question for the user/, @mail.encoded
    end

    should 'have the answer in the body' do
      assert_match /is the answer for the user/, @mail.encoded
    end

    should "use the User's name in the from" do
      assert_match /From:.*#{@user.name}/, @mail.encoded
    end

    should "have (Redmine) in the from to show it came from Redmine" do
      assert_match /From:.*Redmine/, @mail.encoded
    end

    should "have the redmine system email address as the from" do
      assert_match /From:.*#{Setting.mail_from}/, @mail.encoded
    end

    should "have the X-Redmine-Question-Answer header with the issue and journal ids" do
      assert_match /X-Redmine-Question-Answer.*#{@issue.id}-#{@journal_with_answer.id}/, @mail.encoded
    end
  end

end
