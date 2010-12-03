class CleanupQuestionsOnDeletedJournals < ActiveRecord::Migration
  def self.up
    # Delete questions with an invalid journal link
    Question.all.each do |question|
      question.destroy if question.journal.nil?
    end
  end

  def self.down
    # No-op
  end
end
