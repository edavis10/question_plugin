require 'redmine'

require 'question_journal_patch'
require 'question_query_patch'
require 'question_issue_patch'
require 'question_queries_helper_patch'
require 'question_issue_hooks'
require 'question_layout_hooks'

Redmine::Plugin.register :question_plugin do
  name 'Redmine Question plugin'
  author 'Eric Davis'
  description 'This is a plugin for Redmine that will allow users to ask questions to each other in issue notes'
  version '0.1.0'
end

ActiveRecord::Base.observers << :journal_questions_observer
