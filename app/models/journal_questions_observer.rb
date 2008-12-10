require_dependency 'journal'

class JournalQuestionsObserver < ActiveRecord::Observer
  observe :journal
  
  def after_save(journal)
    debugger
    RAILS_DEFAULT_LOGGER.debug 'in observer'
  end
end
