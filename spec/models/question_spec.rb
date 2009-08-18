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

describe Question, "#close!" do
  include QuestionSpecHelper

  it 'should remove a question' do
    journal = mock_model(Journal)
    question = question_factory(1)
    QuestionMailer.stub!(:deliver_answered_question)
    question.should_receive(:destroy).and_return(true)

    question.close!(journal)
  end

  it 'should send a Question Mail when closing a question' do
    journal = mock_model(Journal)
    question = question_factory(1)
    question.stub!(:destroy)
    QuestionMailer.should_receive(:deliver_answered_question).with(question, journal)
    question.close!(journal)
  end
end

