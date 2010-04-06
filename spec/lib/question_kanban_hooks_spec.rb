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

  describe 'any open questions' do
    it 'should be a red image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue,
                                      :opened => false
                                      )

      journal2 = Journal.generate!(:issue => @issue)
      journal2.question = Question.new(
                                       :author => @author,
                                       :issue => @issue,
                                       :opened => true
                                      )

      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.red')
    end
  end

  describe 'all closed questions' do
    it 'should be a black image' do
      journal = Journal.generate!(:issue => @issue)
      journal.question = Question.new(
                                      :author => @author,
                                      :issue => @issue,
                                      :opened => false
                                      )

      journal2 = Journal.generate!(:issue => @issue)
      journal2.question = Question.new(
                                       :author => @author,
                                       :issue => @issue,
                                       :opened => false
                                      )

      response.body = call_hook(:issue => @issue)

      response.should have_tag('a img.black')
    end
  end

  describe 'with a Journal with a note from' do
    describe 'the assigned to user' do
      it 'should not show a bubble' do
        journal = Journal.generate!(:issue => @issue, :user => @assigned_to, :notes => 'a note')
        
        response.body = call_hook(:issue => @issue)
        response.should_not have_tag('a img[class=updated-note]')
      end
    end

    describe 'a random user' do
      it 'should not show a bubble' do
        journal = Journal.generate!(:issue => @issue, :user => User.generate!, :notes => 'a note')

        response.body = call_hook(:issue => @issue)
        response.should_not have_tag('a img[class=updated-note]')
      end
    end

    describe 'a user who as asked a question' do
      it 'should show the bubble' do
        askee = User.generate!
        questioned = Journal.generate!(:issue => @issue)
        questioned.question = Question.new(:assigned_to => askee,
                                           :author => @author,
                                           :issue => @issue,
                                           :opened => true
                                           )
        
        
        journal = Journal.generate!(:issue => @issue, :user => askee, :notes => 'a note')

        response.body = call_hook(:issue => @issue)
        response.should have_tag('img[class=updated-note]')
      end
    end
  end
  

end
