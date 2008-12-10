require File.dirname(__FILE__) + '/../spec_helper'
require 'digest/md5'

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

describe QuestionIssueHooks, 'controller_issues_edit_before_select' do
  def call_hook(context)
    return QuestionIssueHooks.instance.controller_issues_edit_before_save( context )
  end
  
  before(:each) do
    @journal = mock_model(Journal)
    @issue = mock_model(Issue, :pending_question? => false)
    @question = mock_model(Question)
  end
  
  it 'should do nothing when no question is asked' do
    @journal.should_not_receive(:question)
    @journal.should_not_receive(:question=)
    @context = { 
      :params => { },
      :journal => @journal
    }
    call_hook(@context).should eql('')
  end

  it 'should check if the journal has a question' do
    @journal.should_receive(:question).and_return(@question)

    @context = { 
      :params => { :note => { :question_assigned_to => '1'}},
      :journal => @journal
    }
    call_hook(@context).should eql('')
  end

  it 'should create a new question for the journal' do
    @journal.stub!(:question).and_return(nil)
    @journal.stub!(:issue).and_return(@issue)
    @journal.should_receive(:question=)

    @user = mock_model(User)
    User.stub!(:find).with(1).and_return(@user)
    QuestionIssueHooks.instance.should_receive(:assign_question_to_user).with(@journal, @user)

    @context = { 
      :params => { :note => { :question_assigned_to => '1'}},
      :journal => @journal
    }

    call_hook(@context).should eql('')
  end  
  
  it 'should create a new question with no assigned_to user if the parameter is anyone' do
    @journal.stub!(:question).and_return(nil)
    @journal.stub!(:issue).and_return(@issue)
    @journal.should_receive(:question=)

    @context = { 
      :params => { :note => { :question_assigned_to => 'anyone'}},
      :journal => @journal
    }

    call_hook(@context).should eql('')
  end
end

describe QuestionIssueHooks, 'assign_question_to_user' do
  it 'should assign the user to the Journal Question' do
    @journal = mock_model(Journal)
    @question = mock_model(Question)
    @user = mock_model(User)
    @question.should_receive(:assigned_to=)
    @journal.should_receive(:question).and_return(@question)
    
    QuestionIssueHooks.instance.send(:assign_question_to_user, @journal, @user)
  end
end

describe QuestionIssueHooks, 'view_issues_history_journal_bottom with a journal and question' do
  before(:each) do
    @user = mock_model(User, :to_s => "A user", :mail => 'user@example.com')
    @question = mock_model(Question, :assigned_to => @user, :opened? => true)
    @context = { 
      :journal => mock_model(Journal, :question => @question)
    }
    
    @output = QuestionIssueHooks.instance.view_issues_history_journal_bottom( @context )
  end
  
  it 'should use JavaScript' do
    @output.should match(/javascript/i)
  end

  it 'should add a CSS class' do
    @output.should match(/addClassName/i)
  end

  it 'should display the users gravatar' do
    user_digest = Digest::MD5.hexdigest(@user.mail)
    @output.should match(/#{user_digest}/i)
  end
  
  it 'should insert a string into the h4>div' do
    @output.should match(/h4 div/i)
  end
end

describe QuestionIssueHooks, 'view_issues_history_journal_bottom with a journal and no question' do
  it 'should not render anything' do
    @context = { 
      :journal => mock_model(Journal, :question => nil)
    }
    
    QuestionIssueHooks.instance.view_issues_history_journal_bottom( @context ).should eql('')
  end
end

describe QuestionIssueHooks, 'view_issues_sidebar_issues_bottom with a project' do
  before(:each) do
    @project = mock_model(Project)
    @context = { :project => @project }
  end
  
  def call_hook(context)
    return QuestionIssueHooks.instance.view_issues_sidebar_issues_bottom(context)
  end
  
  it 'should get the number of questions for the current user on the project' do
    Question.should_receive(:count).and_return(10)
    call_hook(@context)
  end

  describe 'with questions' do
    before(:each) do
      Question.stub!(:count).and_return(10)
    end

    it 'should return a link to my_issue_filter' do
      call_hook(@context).should match(/my_issue_filter/)
    end
    
    it 'should display the number of questions in the link body' do
      call_hook(@context).should match(/10/)
    end
  end
  
  describe 'without questions' do
    it 'should not return anything' do
      Question.should_receive(:count).and_return(0)
      call_hook(@context).should eql('')
    end
  end
end

describe QuestionIssueHooks, 'view_issues_sidebar_issues_bottom without a project' do
  before(:each) do
    @context = { }
    @user = mock_model(User)
    User.stub!(:current).and_return(@user)
  end
  
  def call_hook(context)
    return QuestionIssueHooks.instance.view_issues_sidebar_issues_bottom(context)
  end
  
  it 'should get the number of questions for the current user on all projects' do
    Question.should_receive(:count).with(:conditions => { :assigned_to_id => @user, :opened => true}).and_return(10)
    call_hook(@context)
  end

  describe 'with questions' do
    before(:each) do
      Question.stub!(:count).and_return(10)
    end

    it 'should return a link to my_issue_filter' do
      call_hook(@context).should match(/my_issue_filter/)
    end
    
    it 'should display the number of questions in the link body' do
      call_hook(@context).should match(/10/)
    end
  end
  
  describe 'without questions' do
    it 'should not return anything' do
      Question.should_receive(:count).and_return(0)
      call_hook(@context).should eql('')
    end
  end
end

