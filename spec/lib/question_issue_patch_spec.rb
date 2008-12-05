require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionIssuePatch do
  it 'should add a has_many association to Issue' do
    Issue.should have_association(:questions, :has_many)
  end
end

