class AddOpenedToQuestions < ActiveRecord::Migration
  def self.up
    unless Question.columns_hash.key? "opened"
      say_with_time("Adding the opened field back in.  See https://projects.littlestreamsoftware.com/issues/2230") do
        add_column :questions, :opened, :boolean, :default => true
      end
    end
  end

  def self.down
    # No-op
  end
end
