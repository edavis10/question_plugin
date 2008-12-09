require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionIssuePatch do
  it 'should add a has_many association to Issue' do
    Issue.should have_association(:questions, :has_many)
  end
end

describe QuestionIssuePatch,"#formatted_questions with no questions" do
  it 'should return an empty string' do
    @issue = Issue.new
    @issue.formatted_questions.should eql('')
  end
end

describe QuestionIssuePatch,"#formatted_questions with questions" do
  it 'should return the first 120 characters of the question' do
    content = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
    question = mock_model(Question)
    @issue = Issue.new
    @issue.should_receive(:questions).twice.and_return([question])
    Question.should_receive(:formatted_list).with([question]).and_return(content[0,120])
    
    question_content = @issue.formatted_questions
    question_content.should_not be_blank
    question_content.should_not match(/really work/)
    question_content.should match(/This is a journal note/)
  end
end
