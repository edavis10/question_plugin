require File.dirname(__FILE__) + '/../spec_helper'

describe Question, 'associations' do
  it 'should belong to a journal' do
    association = Question.reflect_on_association(:journal)
    association.should_not be_nil
    association.name.should eql(:journal)
    association.macro.should eql(:belongs_to)
  end

  it 'should belong to an author' do
    association = Question.reflect_on_association(:author)
    association.should_not be_nil
    association.name.should eql(:author)
    association.macro.should eql(:belongs_to)
  end

  it 'should belong to an assigned user' do
    association = Question.reflect_on_association(:assigned_to)
    association.should_not be_nil
    association.name.should eql(:assigned_to)
    association.macro.should eql(:belongs_to)
  end

  it 'should belong to an issue' do
    association = Question.reflect_on_association(:issue)
    association.should_not be_nil
    association.name.should eql(:issue)
    association.macro.should eql(:belongs_to)
  end
  
end
