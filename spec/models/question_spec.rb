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
    question.errors.on(:journal).should include("activerecord_error_blank")
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
    question.errors.on(:author).should include("activerecord_error_blank")
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
    question.errors.on(:issue).should include("activerecord_error_blank")
    
  end
  
end
