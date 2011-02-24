require_dependency 'journal'

class JournalQuestionsObserver < ActiveRecord::Observer
  observe :journal
  
  def after_create(journal)
    if journal.question
      journal.question.save
    end

    # Close any open questions
    if journal.issue && journal.issue.pending_question?(journal.user)
      journal.issue.close_pending_questions(journal.user, journal)
    end
  end
end
