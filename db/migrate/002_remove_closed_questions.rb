class RemoveClosedQuestions < ActiveRecord::Migration
  def self.up
    say("This migration removed based on feedback. See https://projects.littlestreamsoftware.com/issues/2230")
  end

  def self.down
    # No-op
  end
end
