require File.dirname(__FILE__) + '/../spec_helper'

describe Question, 'associations' do
  it 'should belong to a journal' do
    Question.should have_association(:journal, :belongs_to)
  end

  it 'should belong to an author' do
    Question.should have_association(:author, :belongs_to)
  end

  it 'should belong to an assigned user' do
    Question.should have_association(:assigned_to, :belongs_to)
  end

  it 'should belong to an issue' do
    Question.should have_association(:issue, :belongs_to)
  end
  
end
