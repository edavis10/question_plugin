require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  should_belong_to :journal
  should_belong_to :author
  should_belong_to :assigned_to
  should_belong_to :issue

  should_validate_presence_of :journal
  should_validate_presence_of :author
  should_validate_presence_of :issue

  context "#close!" do
    context "on an open question" do
      setup do
        @question = Question.spawn(:opened => true)
        @closing_journal = Journal.generate!
      end

      should "change an open question to a closed one" do
        @question.close!(@closing_journal)

        assert !@question.new_record?
        assert !@question.opened?
      end

    end

    context "on a closed question" do
      setup do
        ActionMailer::Base.deliveries.clear
        @question = Question.new(:opened => false)
      end
      
      should "do nothing" do
        @question.close!

        assert @question.new_record?
      end
      
    end
    
  end
  
end
