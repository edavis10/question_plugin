require File.dirname(__FILE__) + '/../spec_helper'

describe JournalQuestionsObserver do
  it 'should observer journals' do
    ActiveRecord::Base.observers.should include(:journal_questions_observer)
  end
end

describe JournalQuestionsObserver, '#after_save with no question' do
  it 'should do nothing'
end

describe JournalQuestionsObserver, '#after_save with a question' do
  it 'should deliver an email'
end
