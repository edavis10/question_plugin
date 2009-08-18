class RemoveClosedQuestions < ActiveRecord::Migration
  def self.up
    say_with_time("Removing closed questions") do
      Question.destroy_all({:opened => false})
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
