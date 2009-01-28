require File.dirname(__FILE__) + '/../spec_helper'

describe JournalQuestionsObserver do
  it 'should observer journals' do
    ActiveRecord::Base.observers.should include(:journal_questions_observer)
  end
end

describe JournalQuestionsObserver, '#after_create with no question' do
  it 'should not send an email' do
    journal = mock_model(Journal, :question => nil)
    journal.stub!(:issue).and_return(nil)
    QuestionMailer.should_not_receive(:deliver_asked_question)
    JournalQuestionsObserver.instance.after_create(journal)
  end
end

describe JournalQuestionsObserver, '#after_create with a question' do
  it 'should deliver an email' do
    question = mock_model(Question)
    journal = mock_model(Journal, :question => question, :issue => nil)
    QuestionMailer.should_receive(:deliver_asked_question).with(journal)
    JournalQuestionsObserver.instance.after_create(journal)
  end
end

describe JournalQuestionsObserver, '#after_create' do
  it 'should close all pending questions for the journal submitter' do
    author = mock_model(User)
    issue = mock_model(Issue)
    journal = mock_model(Journal, :question => nil)
    
    issue.should_receive(:pending_question?).with(author).and_return(true)
    issue.should_receive(:close_pending_questions).with(author, journal)

    journal.should_receive(:user).at_least(:once).and_return(author)
    journal.stub!(:issue).and_return(issue)
    
    JournalQuestionsObserver.instance.after_create(journal)
  end
end
