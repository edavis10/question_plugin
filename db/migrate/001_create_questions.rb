class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.column :journal_id, :integer
      t.column :author_id, :integer
      t.column :assigned_to_id, :integer
      t.column :opened, :boolean, :default => true
      t.column :issue_id, :integer
    end
  end

  def self.down
    drop_table :questions
  end
end
