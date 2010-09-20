require 'redmine'

require 'question_issue_hooks'
require 'question_kanban_hooks'
require 'question_layout_hooks'
require 'question_journal_hooks'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :question_plugin do
  require_dependency 'issue'
  Issue.send(:include, QuestionIssuePatch) unless Issue.included_modules.include? QuestionIssuePatch

  require_dependency 'journal'
  Journal.send(:include, QuestionJournalPatch) unless Journal.included_modules.include? QuestionJournalPatch

  require_dependency 'queries_helper'
  QueriesHelper.send(:include, QuestionQueriesHelperPatch) unless QueriesHelper.included_modules.include? QuestionQueriesHelperPatch

  require_dependency "query"
  Query.send(:include, QuestionQueryPatch) unless Query.included_modules.include? QuestionQueryPatch
end

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
require 'question_plugin/hooks/view_user_kanbans_show_contextual_top_hook'
