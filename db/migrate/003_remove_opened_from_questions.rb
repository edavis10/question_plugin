class RemoveOpenedFromQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :opened
  end

  def self.down
    add_column :questions, :opened, :boolean, :default => true
  end
end
