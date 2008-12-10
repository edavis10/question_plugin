require_dependency 'journal'

class JournalQuestionsObserver < ActiveRecord::Observer
  observe :journal
  
  def after_save(journal)
    QuestionMailer.deliver_asked_question(journal) if journal.question
  end
end
