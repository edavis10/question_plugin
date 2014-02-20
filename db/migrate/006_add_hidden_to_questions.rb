class AddHiddenToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :questions, :hidden
  end
end
