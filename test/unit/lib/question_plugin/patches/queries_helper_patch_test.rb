require File.dirname(__FILE__) + '/../../../../test_helper'

require 'queries_helper'

# TODO: rename under the namespace
class QuestionQueriesHelperPatchTest < HelperTestCase
  include ApplicationHelper
  include QueriesHelper
  include QuestionQueriesHelperPatch
  include ActionView::Helpers::TextHelper
  include ActionController::Assertions::SelectorAssertions

  def setup
    super
  end

  def for_assert_select(response_text)
    @doc = HTML::Document.new(response_text)
    @doc.root
  end
  
  context "#format_questions with no questions" do
    should 'return an empty string' do
      assert_equal '', format_questions([])
    end
  end

  context "#format_questions with one question" do
    setup do
      @content = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @author = User.generate!
      @assignee = User.generate!
      @question = Question.new(:issue => @issue, :author => @author, :assigned_to => @assignee)
      @issue.journal_notes = @content
      @issue.extra_journal_attributes = { :question => @question }
      assert @issue.save
      @questions = [@question]
    end
    
    should 'not be blank' do
      assert !format_questions(@questions).blank?
    end
    
    should 'show the first 120 characters of the question in the summary' do
      question_content = for_assert_select(format_questions(@questions))

      assert_select question_content, "span.question_summary", :text => /This is a journal note/
      assert_select question_content, "span.question_summary", :text => /really work/, :count => 0
    end
    
    should 'have ellipses if when over 120 characters of content' do
      question_content = for_assert_select(format_questions(@questions))
      assert_select question_content, "span.question_summary", :text => /\.\.\./
    end

    should 'not have ellipses when there are under 120 characters of content' do
      content = 'Short question'
      @journal = @issue.journals.last
      @journal.notes = content
      assert @journal.save
      assert @question.reload

      question_content = for_assert_select(format_questions(@questions))

      assert_select question_content, "span.question_summary", :text => /\.\.\./, :count => 0
    end

  end

  context "#format_questions with multiple questions" do
    setup do
      @content_one = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
      @content_two = 'Another journal with a unique content that is well over 120 characters but it will be ok becasue it is truncated soon.  Maybe.'

      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @author = User.generate!
      @assignee = User.generate!
      @question = Question.new(:issue => @issue, :author => @author, :assigned_to => @assignee)
      @question_two = Question.new(:issue => @issue, :author => @author, :assigned_to => @assignee)

      @issue.journal_notes = @content_one
      @issue.extra_journal_attributes = { :question => @question }
      assert @issue.save && @issue.reload
      @journal_one = @issue.journals.last
      
      @issue.journal_notes = @content_two
      @issue.extra_journal_attributes = { :question => @question_two }
      assert @issue.save && @issue.reload
      @journal_two = @issue.journals.last
      
      @questions = [@question, @question_two]
    end
    
    should 'not be empty' do
      assert !format_questions(@questions).empty?
    end
    
    should 'show the first 120 characters of each question in the summary' do
      question_content = for_assert_select(format_questions(@questions))
      assert_select question_content, "span.question_summary", :text => /This is a journal note/
      assert_select question_content, "span.question_summary", :text => /really work/, :count => 0

      assert_select question_content, "span.question_summary", :text => /unique/
      assert_select question_content, "span.question_summary", :text => /maybe/, :count => 0
    end
  end

  context "#question_column_content" do
    setup do
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @author = User.generate!
      @assignee = User.generate!
      @question = Question.new(:issue => @issue, :author => @author, :assigned_to => @assignee)
      @issue.journal_notes = "A question"
      @issue.extra_journal_attributes = { :question => @question }
      assert @issue.save
    end
   
    should 'use a special format for the questions column' do
      question_column = Query.available_columns.select {|c| c.name == :formatted_questions}.first
      content = for_assert_select(question_column_content(question_column, @issue))
      assert_select content, 'ol'
    end

    should 'use the default format for all other columns' do
      Query.available_columns.each do |column|
        next if column.name == :formatted_questions
        content = for_assert_select(question_column_content(column, @issue))
        assert_select content, 'ol', :count => 0
      end
    end
    
  end
end
