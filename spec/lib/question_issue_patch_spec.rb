require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionIssuePatch do
  it 'should add a has_many association to Issue' do
    Issue.should have_association(:questions, :has_many)
  end
end

describe QuestionIssuePatch,"#pending_question?" do
  before(:each) do
    @user = mock_model(User)
  end
  
  it 'should return false if there are no open questions' do
    question_mock = mock('question_mock')
    question_mock.stub!(:find).and_return([])
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.pending_question?(@user).should be_false
  end

  it 'should return false if there are no open questions for the current user' do
    @other_user = mock_model(User)
    question_one = mock_model(Question, :assigned_to => @other_user, :for_anyone? => false)
    question_two = mock_model(Question, :assigned_to => @other_user, :for_anyone? => false)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question_one, question_two])
    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.pending_question?(@user).should be_false
  end

  it 'should return true if there is an open question for the current user' do
    @other_user = mock_model(User)
    question_one = mock_model(Question, :assigned_to => @other_user, :for_anyone? => false)
    question_two = mock_model(Question, :assigned_to => @user, :for_anyone? => false)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question_one, question_two])
    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.pending_question?(@user).should be_true
    
  end

  it 'should return true if there is an open question for anyone' do
    @other_user = mock_model(User)
    question_one = mock_model(Question, :assigned_to => @other_user, :for_anyone? => false)
    question_two = mock_model(Question, :assigned_to => nil, :for_anyone? => true)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question_one, question_two])
    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.pending_question?(@user).should be_true
    
  end
end

describe QuestionIssuePatch,"#close_pending_questions" do
  it 'should close any open questions for user' do
    @user = mock_model(User)
    @journal = mock_model(Journal)
    question = mock_model(Question, :opened => true, :assigned_to => @user)
    question.should_receive(:close!).and_return(question)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question])

    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.close_pending_questions(@user, @journal)
  end
  
  it 'should close any questions for anyone' do
    @user = mock_model(User)
    @journal = mock_model(Journal)
    question = mock_model(Question, :opened => true, :assigned_to => nil, :for_anyone? => true)
    question.should_receive(:close!).and_return(question)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question])

    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.close_pending_questions(@user, @journal)
  end

  it 'should not close any questions for other users' do
    @user = mock_model(User)
    @journal = mock_model(Journal)
    @other_user = mock_model(User)
    question = mock_model(Question, :opened => true, :assigned_to => @other_user, :for_anyone? => false)
    question.should_not_receive(:close!)
    question_mock = mock('question_mock')
    question_mock.should_receive(:find).and_return([question])

    
    @issue = Issue.new
    @issue.should_receive(:open_questions).and_return(question_mock)
    @issue.close_pending_questions(@user, @journal)
  end

end
