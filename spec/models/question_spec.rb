require File.dirname(__FILE__) + '/../spec_helper'

describe Question, 'associations' do
  it 'should belong to a journal' do
    Question.should have_association(:journal, :belongs_to)
  end

  it 'should belong to an author' do
    Question.should have_association(:author, :belongs_to)
  end

  it 'should belong to an assigned user' do
    Question.should have_association(:assigned_to, :belongs_to)
  end

  it 'should belong to an issue' do
    Question.should have_association(:issue, :belongs_to)
  end
  
end

describe Question, 'requires' do
  include QuestionSpecHelper
  
  it 'a journal' do
    question = question_factory(1)
    user = mock_model(User)
    question.stub!(:author).and_return(user)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    issue = mock_model(Issue)
    question.stub!(:issue).and_return(issue)
    
    question.should_not be_valid
    question.errors.on(:journal).should eql("can't be blank")
  end

  it 'an author' do
    question = question_factory(1)
    journal = mock_model(Journal)
    question.stub!(:journal).and_return(journal)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    issue = mock_model(Issue)
    question.stub!(:issue).and_return(issue)
    
    question.should_not be_valid
    question.errors.on(:author).should eql("can't be blank")
  end

  it 'an issue' do
    question = question_factory(1)
    user = mock_model(User)
    question.stub!(:author).and_return(user)
    journal = mock_model(Journal)
    question.stub!(:journal).and_return(journal)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    
    question.should_not be_valid
    question.errors.on(:issue).should eql("can't be blank")
    
  end
  
end

describe Question, "#close! on a closed question" do
  include QuestionSpecHelper

  it 'should do nothing' do
    question = question_factory(1, { :opened => false })
    question.should_not_receive(:save)
    question.should_not_receive(:save!)
    proc { 
      question.close!
    }.should_not change(question, :opened)
  end
  
  it 'should not send a Question Mail' do
    question = question_factory(1, { :opened => false })
    QuestionMailer.should_not_receive(:deliver_answered_question)
    question.close!
  end
end

describe Question, "#close! on an open question" do
  include QuestionSpecHelper

  it 'should change an open question to a closed one' do
    journal = mock_model(Journal)
    question = question_factory(1, { :opened => true })
    question.should_receive(:save!)
    QuestionMailer.stub!(:deliver_answered_question)
    proc { 
      question.close!(journal)
    }.should change(question, :opened).to(false)
  end

  it 'should send a Question Mail when closing an open question' do
    journal = mock_model(Journal)
    question = question_factory(1, { :opened => true })
    question.stub!(:save!)
    QuestionMailer.should_receive(:deliver_answered_question).with(question, journal)
    question.close!(journal)
  end
end

