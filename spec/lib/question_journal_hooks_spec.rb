require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionJournalHooks, '#views_journals_notes_form_after_notes' do
  describe 'should render a select' do
    before(:each) do
      @user1 = mock_model(User, :id => 1, :name => 'Test one')
      @user2 = mock_model(User, :id => 2, :name => 'Test two')
      @issue = mock_model(Issue)
      @issue.should_receive(:assignable_users).and_return([@user1, @user2])
      @question = mock_model(Question, :assigned_to => @user2, :opened => true)
      @journal = mock_model(Journal, :issue => @issue, :question => @question)
      @context = { :journal => @journal }
    end

    it 'with options for each user' do
      QuestionJournalHooks.instance.view_journals_notes_form_after_notes( @context ).should have_tag('option',/Test one/)
    end

    it 'with an "Anyone" option' do
      QuestionJournalHooks.instance.view_journals_notes_form_after_notes( @context ).should have_tag('option',/Anyone/)
    end

    it 'with a "Remove" option' do
      QuestionJournalHooks.instance.view_journals_notes_form_after_notes( @context ).should have_tag('option',/remove/i)
    end

    it 'with the current user selected option' do
      QuestionJournalHooks.instance.view_journals_notes_form_after_notes( @context ).should have_tag('option[selected=selected]',/Test two/)
    end
  end
end


describe QuestionJournalHooks, '#controller_journals_edit_post with an empty question' do
  it 'should do nothing' do
    journal = mock_model(Journal)
    context = { 
      :journal => journal,
      :params => { }
    }
    journal.should_not_receive(:question)
    journal.should_not_receive(:question=)
    QuestionJournalHooks.instance.controller_journals_edit_post( context ).should eql('')
  end
end

describe QuestionJournalHooks, '#controller_journals_edit_post with a new question' do
  it 'should create a new question' do
    issue = mock_model(Issue)
    journal = mock_model(Journal, :question => nil, :issue => issue)
    QuestionJournalHooks.instance.should_receive(:add_new_question).with(journal, 'anyone')
    context = { 
      :journal => journal,
      :params => { :question => { :assigned_to_id => 'anyone'}}
    }
    QuestionJournalHooks.instance.controller_journals_edit_post( context ).should eql('')
  end
end

describe QuestionJournalHooks, '#controller_journals_edit_post with a reassigned question' do
  it 'should change the assignment of the question' do
    issue = mock_model(Issue)
    question = mock_model(Question, :assigned_to_id => 2, :opened => true)
    question.should_receive(:update_attributes).with({ :assigned_to_id => 'anyone'}).and_return(true)
    journal = mock_model(Journal, :question => nil, :issue => issue, :question => question)
    context = { 
      :journal => journal,
      :params => { :question => { :assigned_to_id => 'anyone'}}
    }
    QuestionJournalHooks.instance.controller_journals_edit_post( context ).should eql('')
  end
end

describe QuestionJournalHooks, '#controller_journals_edit_post with a removed question' do
  it 'should destroy the question' do
    issue = mock_model(Issue)
    question = mock_model(Question, :assigned_to_id => 2, :opened => true)
    journal = mock_model(Journal, :question => nil, :issue => issue, :question => question)
    question.should_receive(:destroy).and_return(true)
    context = { 
      :journal => journal,
      :params => { :question => { :assigned_to_id => 'remove'}}
    }
    QuestionJournalHooks.instance.controller_journals_edit_post( context ).should eql('')
  end
end

describe QuestionJournalHooks, '#view_journals_update_rjs_bottom with a question for anyone' do
  before(:each) do
    @rjs_page = ''
    @question = mock_model(Question, :opened? => true, :assigned_to => nil)
    @journal = mock_model(Journal, :reload => true, :question => @question)
    @context = { :page => @rjs_page, :journal => @journal}
    QuestionJournalHooks.instance.view_journals_update_rjs_bottom( @context )
  end
  
  it 'should add the CSS class of "question" to the journal div' do
    @rjs_page.should match(/addClassName\('question'\)/)
  end

  it 'should remove all existing question lines using RJS' do
    @rjs_page.should match(/question-line.*remove/)
  end

  it 'should add the generated HTML to the top of the side div' do
    @rjs_page.should match(/insert.*top/)
  end

end

describe QuestionJournalHooks, '#view_journals_update_rjs_bottom without a question' do
  before(:each) do
    @rjs_page = ''
    @journal = mock_model(Journal, :reload => true, :question => nil)
    @context = { :page => @rjs_page, :journal => @journal}
    QuestionJournalHooks.instance.view_journals_update_rjs_bottom( @context )
  end
  
  it 'should remove the CSS class of "question" from the journal div' do
    @rjs_page.should match(/removeClassName\('question'\)/)
  end

  it 'should remove all existing question lines using RJS' do
    @rjs_page.should match(/question-line.*remove/)
  end
end
