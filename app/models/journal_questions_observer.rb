require_dependency 'journal'

class JournalQuestionsObserver < ActiveRecord::Observer
  observe :journal
  
  def after_create(journal)
    QuestionMailer.deliver_asked_question(journal) if journal.question

    # Close any open questions
    if journal.issue && journal.issue.pending_question?(journal.user)
      journal.issue.close_pending_questions(journal.user, journal)
    end
  end
end
