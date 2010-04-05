require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionIssueHooks, '#view_kanbans_issue_details', :type => :view do
  def call_hook(context)
    return QuestionKanbanHooks.instance.view_kanbans_issue_details( context )
  end

  before(:each) do
    @author = User.generate!
    @assigned_to = User.generate!
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project, :author => @author, :assigned_to => @assigned_to)
  end    

  describe 'no issue' do
    it 'should be nothing' do
      response.body = call_hook(:issue => nil)

      response.should be_blank
    end
  end
  
  describe 'no questions' do
    it 'should be a gray image' do
      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.gray')
    end
  end

  describe 'all open questions' do
    it 'should be a red image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue
                                      )
      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.red')
    end
  end

  describe 'all closed questions, last journal update from non assigned user' do
    it 'should be a green image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue,
                                      :opened => false
                                      )
      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.green')
    end
  end

  describe 'some closed questions, last journal update from assigned user' do
    it 'should be a orange image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue,
                                      :opened => false
                                      )

      journal2 = Journal.generate!(:issue => @issue, :user => @assigned_to)
      journal2.question = Question.new(
                                       :author => @author,
                                       :issue => @issue,
                                       :opened => true
                                      )

      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.orange')
    end
  end

  describe 'all closed questions, last journal update from assigned user' do
    it 'should be a black image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue,
                                      :opened => false
                                      )

      journal2 = Journal.generate!(:issue => @issue, :user => @assigned_to)
      journal2.question = Question.new(
                                       :author => @author,
                                       :issue => @issue,
                                       :opened => false
                                      )

      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.black')
    end
  end

end
