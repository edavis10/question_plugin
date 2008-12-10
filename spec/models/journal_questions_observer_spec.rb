require File.dirname(__FILE__) + '/../spec_helper'

describe JournalQuestionsObserver do
  it 'should observer journals' do
    ActiveRecord::Base.observers.should include(:journal_questions_observer)
  end
end

describe JournalQuestionsObserver, '#after_save with no question' do
  it 'should do nothing' do
    journal = mock_model(Journal, :question => nil)
    QuestionMailer.should_not_receive(:deliver_asked_question)
    JournalQuestionsObserver.instance.after_save(journal)
  end
end

describe JournalQuestionsObserver, '#after_save with a question' do
  it 'should deliver an email' do
    question = mock_model(Question)
    journal = mock_model(Journal, :question => question)
    QuestionMailer.should_receive(:deliver_asked_question).with(question)
    JournalQuestionsObserver.instance.after_save(journal)
  end
end
