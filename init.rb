require 'redmine'

require 'question_plugin/hooks/issue_hooks'
require 'question_plugin/hooks/kanban_hooks'
require 'question_plugin/hooks/layout_hooks'
require 'question_plugin/hooks/journal_hooks'

Rails.configuration.to_prepare do
  require_dependency 'issue'
  Issue.send(:include, QuestionPlugin::Patches::IssuePatch) unless Issue.included_modules.include? QuestionPlugin::Patches::IssuePatch

  require_dependency 'journal'
  Journal.send(:include, QuestionPlugin::Patches::JournalPatch) unless Journal.included_modules.include? QuestionPlugin::Patches::JournalPatch

  require_dependency 'application_helper'
  ApplicationHelper.send(:include, QuestionPlugin::Patches::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include? QuestionPlugin::Patches::ApplicationHelperPatch

  if ActiveSupport::Dependencies::search_for_file('journal_observer')
    require_dependency 'journal_observer'
    JournalObserver.send(:include, QuestionPlugin::Patches::JournalObserverPatch) unless JournalObserver.included_modules.include? QuestionPlugin::Patches::JournalObserverPatch
  end

  if ActiveSupport::Dependencies::search_for_file('issue_queries_helper')
    require_dependency 'issue_queries_helper'
    IssueQueriesHelper.send(:include, QuestionPlugin::Patches::QueriesHelperPatch) unless IssueQueriesHelper.included_modules.include? QuestionPlugin::Patches::QueriesHelperPatch
  else
    require_dependency 'queries_helper'
    QueriesHelper.send(:include, QuestionPlugin::Patches::QueriesHelperPatch) unless QueriesHelper.included_modules.include? QuestionPlugin::Patches::QueriesHelperPatch
  end

  if ActiveSupport::Dependencies::search_for_file('issue_query')
    require_dependency 'issue_query'
    IssueQuery.send(:include, QuestionPlugin::Patches::QueryPatch) unless Query.included_modules.include? QuestionPlugin::Patches::QueryPatch
  else
    require_dependency 'query'
    Query.send(:include, QuestionPlugin::Patches::QueryPatch) unless Query.included_modules.include? QuestionPlugin::Patches::QueryPatch
  end
end

p = Redmine::Plugin.register :question_plugin do
  name 'Redmine Question plugin'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/projects/redmine-questions" if respond_to?(:url)
  author_url 'http://www.littlestreamsoftware.com' if respond_to?(:author_url)
  description 'This is a plugin for Redmine that will allow users to ask questions to each other in issue notes'
  version '0.3.0'

  requires_redmine :version_or_higher => '3.0.0'

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
