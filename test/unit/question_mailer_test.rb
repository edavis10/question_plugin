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

  context "#question_reminders" do
    setup do
      @user = User.generate!(:firstname => 'Test', :lastname => 'User', :mail => 'test@example.org')
      @user2 = User.generate!(:firstname => 'Test2', :lastname => 'User', :mail => 'test2@example.org')
      @user3 = User.generate!(:firstname => 'Test3', :lastname => 'User', :mail => 'test3@example.org')
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project, :subject => "Add new stuff issue1")
      @another_issue = Issue.generate_for_project!(@project, :subject => "Add new stuff issue2")

      @question1 = Question.generate!(:assigned_to => @user, :author => @user2, :issue => @issue)
      @journal1 = Journal.generate!(:details => [], :notes => "This is the question1 for the user", :question => @question1)

      @question2 = Question.generate!(:assigned_to => @user, :author => @user2, :issue => @another_issue)
      @journal2 = Journal.generate!(:details => [], :notes => "This is the question2 for the user", :question => @question2)

      @question3 = Question.generate!(:assigned_to => @user2, :author => @user3, :issue => @another_issue)
      @journal3 = Journal.generate!(:details => [], :notes => "This is the question3 for the user", :question => @question3)

      # user has questions on @issue and @another_issue
      # user2 has questions on @another_issue
      ActionMailer::Base.deliveries.clear
      Setting.bcc_recipients = '0'

      QuestionMailer.question_reminders
    end
    
    should "send one email per user with open questions" do
       assert_equal 2, ActionMailer::Base.deliveries.count
    end
    
    should "list all questions for a user in the email" do
      user1_mail = select_sent_mail_for(@user.mail).first
      assert user1_mail.body.include?("Add new stuff issue1")
      assert user1_mail.body.include?("Add new stuff issue2")

      user2_mail = select_sent_mail_for(@user2.mail).first
      assert user2_mail.body.include?("Add new stuff issue2")
    end
    
    should "link to the issue with the question in the email" do
      user1_mail = select_sent_mail_for(@user.mail).first
      assert user1_mail.body.include?("http://localhost:3000/issues/#{@issue.id}")
      assert user1_mail.body.include?("http://localhost:3000/issues/#{@another_issue.id}")
    end
    
    should "link to the issues list in the email" do
      user1_mail = select_sent_mail_for(@user.mail).first
      assert user1_mail.body.include?("http://localhost:3000/questions/my_issue_filter")
    end
    

  end

  def select_sent_mail_for(email)
    ActionMailer::Base.deliveries.select {|m| m.to.include?(email) }
  end
  
end
