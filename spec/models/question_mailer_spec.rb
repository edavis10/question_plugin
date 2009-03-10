require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionMailer do
  it 'should be a subclass of Redmines Mailer' do
    QuestionMailer.ancestors.should include(Mailer)
  end
end

describe QuestionMailer, '#asked_question with a question' do
  before(:each) do
    @user = mock_model(User, :name => 'Test User', :mail => 'test@example.org')
    @author = mock_model(User, :name => 'Author', :mail => 'author@example.org')
    @tracker = mock_model(Tracker, :name => 'Bugs')
    @issue = mock_model(Issue, :id => 1000, :tracker => @tracker, :author => nil, :subject => "Add new stuff", :status => nil, :priority => nil, :assigned_to => nil, :category => nil, :fixed_version => nil, :custom_values => [], :description => 'Issue description')
    @question = mock_model(Question, :assigned_to => @user, :author => @author, :issue => @issue)
    @journal = mock_model(Journal, :details => [], :notes => "This is the question for the user", :notes? => true, :question => @question)
    Setting.stub!(:mail_from).and_return("redmine@example.com")
    
    Setting.stub!(:bcc_recipients?).and_return(true)
    @mail = QuestionMailer.create_asked_question(@journal)
  end
  
  it 'should create a mail message' do
    @mail.should be_an_instance_of(TMail::Mail)
  end
  
  it 'should have the subject prefixed with "Question"' do
    @mail.subject.should match(/Question/)
  end
  
  it 'should use the issue subject for the subject line' do
    @mail.subject.should match(/add new stuff/i)
  end

  it 'should use the issue id in the subject line' do
    @mail.subject.should match(/#1000/)
  end

  it 'should be sent to the assigned_to user' do
    @mail.bcc.should include(@user.mail)
  end
  
  it 'should have a link to the issue' do
    @mail.encoded.should match(/issues\/1000/)
  end

  it 'should have a question in the body' do
    @mail.encoded.should match(/is the question for the user/)
  end
  
  it "should use the User's name in the from" do
    @mail.encoded.should match(/From:.*#{@author.name}/)
  end

  it "should have (Redmine) in the from to show it came from Redmine" do
    @mail.encoded.should match(/From:.*Redmine/)
  end

  it "should have the redmine system email address as the from" do
    @mail.encoded.should match(/From:.*#{Setting.mail_from}/)
  end
end


describe QuestionMailer, '#asked_question with a question for anyone' do
  it 'should not be sent to anyone' do
    author = mock_model(User, :name => 'Author', :mail => 'author@example.org')
    tracker = mock_model(Tracker, :name => 'Bugs')
    issue = mock_model(Issue, :id => 1000, :tracker => tracker, :author => nil, :subject => "Add new stuff", :status => nil, :priority => nil, :assigned_to => nil, :category => nil, :fixed_version => nil, :custom_values => [], :description => 'Issue description')
    question = mock_model(Question, :assigned_to => nil, :issue => issue, :author => author)
    journal = mock_model(Journal, :details => [], :notes => "This is the question for the user", :notes? => true, :question => question)
    
    @mail = QuestionMailer.create_asked_question(journal)
    @mail.to.should be_nil
    @mail.cc.should be_nil
    @mail.bcc.should be_nil
  end
end

describe QuestionMailer, '#answered_question' do
  before(:each) do
    @user = mock_model(User, :name => 'Test User', :mail => 'test@example.org')
    @author = mock_model(User, :name => 'Author', :mail => 'author@example.org')
    @tracker = mock_model(Tracker, :name => 'Bugs')
    @issue = mock_model(Issue, :id => 1000, :tracker => @tracker, :author => nil, :subject => "Add new stuff", :status => nil, :priority => nil, :assigned_to => nil, :category => nil, :fixed_version => nil, :custom_values => [], :description => 'Issue description')
    @journal_with_question = mock_model(Journal, :details => [], :notes => "This is the question for the user", :notes? => true)
    @journal_with_answer = mock_model(Journal, :details => [], :notes => "This is the answer for the user", :notes? => true)
    @question = mock_model(Question, :assigned_to => @user, :author => @author, :issue => @issue, :journal => @journal_with_question)
    Setting.stub!(:mail_from).and_return("redmine@example.com")
    
    Setting.stub!(:bcc_recipients?).and_return(true)
    @mail = QuestionMailer.create_answered_question(@question, @journal_with_answer)
  end
  
  it 'should create a mail message' do
    @mail.should be_an_instance_of(TMail::Mail)
  end

  it 'should have the subject prefixed with "Answered"' do
    @mail.subject.should match(/Answered/)
  end

  it 'should use the issue subject for the subject line' do
    @mail.subject.should match(/add new stuff/i)
  end

  it 'should use the issue id in the subject line' do
    @mail.subject.should match(/#1000/)
  end

  it 'should be sent to the question author' do
    @mail.bcc.should include(@author.mail)
  end

  it 'should have a link to the issue' do
    @mail.encoded.should match(/issues\/1000/)
  end

  it 'should have the question in the body' do
    @mail.encoded.should match(/is the question for the user/)
  end

  it 'should have the answer in the body' do
    @mail.encoded.should match(/is the answer for the user/)
  end

  it "should use the User's name in the from" do
    @mail.encoded.should match(/From:.*#{@user.name}/)
  end

  it "should have (Redmine) in the from to show it came from Redmine" do
    @mail.encoded.should match(/From:.*Redmine/)
  end

  it "should have the redmine system email address as the from" do
    @mail.encoded.should match(/From:.*#{Setting.mail_from}/)
  end
end
