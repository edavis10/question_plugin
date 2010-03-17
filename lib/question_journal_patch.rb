module QuestionJournalPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_one :question
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def question_assigned_to
      # TODO: pull out the assigned user on edits
    end
  end
end
