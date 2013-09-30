require 'redmine'

require 'question_issue_hooks'
require 'question_kanban_hooks'
require 'question_layout_hooks'
require 'question_journal_hooks'

Rails.configuration.to_prepare do
  require_dependency 'journal_observer'
  JournalObserver.send(:include, QuestionPlugin::Patches::JournalObserverPatch) unless JournalObserver.included_modules.include? QuestionPlugin::Patches::JournalObserverPatch

  require_dependency 'active_record'
  ActiveRecord::Relation.send(:include, QuestionActiveRecordRelationPatch) unless ActiveRecord::Relation.included_modules.include? QuestionActiveRecordRelationPatch

  require_dependency 'issue'
  Issue.send(:include, QuestionIssuePatch) unless Issue.included_modules.include? QuestionIssuePatch

  require_dependency 'journal'
  Journal.send(:include, QuestionJournalPatch) unless Journal.included_modules.include? QuestionJournalPatch

  if ActiveSupport::Dependencies::search_for_file('issue_queries_helper')
    require_dependency 'issue_queries_helper'
    IssueQueriesHelper.send(:include, QuestionQueriesHelperPatch) unless QueriesHelper.included_modules.include? QuestionQueriesHelperPatch
  else
    require_dependency 'queries_helper'
    QueriesHelper.send(:include, QuestionQueriesHelperPatch) unless QueriesHelper.included_modules.include? QuestionQueriesHelperPatch
  end

  if ActiveSupport::Dependencies::search_for_file('issue_query')
    require_dependency 'issue_query'
    IssueQuery.send(:include, QuestionQueryPatch) unless Query.included_modules.include? QuestionQueryPatch
  else
    require_dependency 'query'
    Query.send(:include, QuestionQueryPatch) unless Query.included_modules.include? QuestionQueryPatch
  end
end

p = Redmine::Plugin.register :question_plugin do
  name 'Redmine Question plugin'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/projects/redmine-questions" if respond_to?(:url)
  author_url 'http://www.littlestreamsoftware.com' if respond_to?(:author_url)
  description 'This is a plugin for Redmine that will allow users to ask questions to each other in issue notes'
  version '0.3.0'

  requires_redmine :version_or_higher => '2.0.0'

  settings :default => {
    :only_members => 1,
    :close_all_questions => 1,
    :obfuscate_author => 0,
    :obfuscate_content => 0,
  }, :partial => 'settings/question_plugin'

end

# Ensure ActionMailer knows where to find the views for the question plugin
view_path = File.join(p.directory, 'app', 'views')
if File.directory?(view_path)
  ActionMailer::Base.prepend_view_path(view_path)
end

require 'question_plugin/hooks/view_user_kanbans_show_contextual_top_hook'
