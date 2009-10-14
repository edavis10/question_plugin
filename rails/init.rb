require 'redmine'

require 'question_journal_patch'
require 'question_query_patch'
require 'question_issue_patch'
require 'question_queries_helper_patch'
require 'question_issue_hooks'
require 'question_layout_hooks'
require 'question_journal_hooks'

Redmine::Plugin.register :question_plugin do
  name 'Redmine Question plugin'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/projects/redmine-questions" if respond_to?(:url)
  author_url 'http://www.littlestreamsoftware.com' if respond_to?(:author_url)
  description 'This is a plugin for Redmine that will allow users to ask questions to each other in issue notes'
  version '0.3.0'

  requires_redmine :version_or_higher => '0.8.0'

end

ActiveRecord::Base.observers << :journal_questions_observer
