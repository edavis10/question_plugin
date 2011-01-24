require File.dirname(__FILE__) + '/../test_helper'

class JournalQuestionsObserverTest < ActiveSupport::TestCase
  context JournalQuestionsObserver do
    should 'observer journals' do
      assert ActiveRecord::Base.observers.include?(:journal_questions_observer)
    end
  end

  context '#after_create' do
    setup do
      ActionMailer::Base.deliveries.clear

      @author = User.generate_with_protected!
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
    end
    
    context 'with no question' do
      should 'not send an email' do
        Journal.create!(:user => @author, :journalized => @issue, :notes => 'No question')

        assert_equal 0, ActionMailer::Base.deliveries.length

      end
    end

    context 'with a question' do
      should 'deliver an email' do
        question_journal = Journal.generate!(:user => @author, :journalized => @issue, :notes => 'Question')
        question = Question.generate!(:assigned_to => @author, :author => @author, :issue => @issue, :journal => question_journal)
        
        Journal.create!(:user => @author, :journalized => @issue, :notes => 'Answer')

        assert_sent_email do |email|
          email.subject =~ /answered/i
        end
      end
    end

    should 'close all pending questions for the journal submitter' do
      question_journal = Journal.generate!(:user => @author, :journalized => @issue, :notes => 'Question')
      question = Question.generate!(:assigned_to => @author, :author => @author, :issue => @issue, :journal => question_journal)

      assert question.reload.opened
      journal = Journal.create!(:user => @author, :journalized => @issue, :notes => 'Answer to a question')
      assert !question.reload.opened
    end
  end
end
