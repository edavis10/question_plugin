require File.dirname(__FILE__) + '/../../../../test_helper'

# TODO: rename under the namespace
class QuestionJournalPatchTest < ActionController::TestCase

  context "Journal" do
    subject {Journal.new}
    should_have_one :question
  end
end
