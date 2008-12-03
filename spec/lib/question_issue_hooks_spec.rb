require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionIssueHooks, 'view_issues_edit_notes_bottom' do
  describe 'should render a select' do
    before(:each) do
      @user1 = mock_model(User, :id => 1, :name => 'Test one')
      @user2 = mock_model(User, :id => 2, :name => 'Test two')
      @issue = mock_model(Issue)
      @issue.should_receive(:assignable_users).and_return([@user1, @user2])
      @context = { :issue => @issue }
    end
    
    it 'with options for each user' do
      QuestionIssueHooks.instance.view_issues_edit_notes_bottom( @context ).should have_tag('option',/Test one/)
    end

    it 'with an "Anyone" option' do
      QuestionIssueHooks.instance.view_issues_edit_notes_bottom( @context ).should have_tag('option',/Anyone/)
    end

    it 'with a blank option' do
      QuestionIssueHooks.instance.view_issues_edit_notes_bottom( @context ).should have_tag('option','')
    end
  end
end
