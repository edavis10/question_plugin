RedmineApp::Application.routes.draw do
  match 'issuequestions/autocomplete_for_user_login/project/:id/issue/:issue_id' => 'issuequestions#autocomplete_for_user_login', :format => false, :as => 'issuequestions_autocomplete_for_user_login', :via => [:get, :post]
  match 'issuequestions/my_issue_filter(/project/:project)' => 'issuequestions#my_issue_filter', :format => false, :as => 'questions_my_issue_filter', :via => [:get, :post]
  match 'issuequestions/user_issue_filter/user/:user_id' => 'issuequestions#user_issue_filter', :format => false, :as => 'questions_user_issue_filter', :via => [:get, :post]
  match 'issuequestions/hide/:id' => 'issuequestions#hide', :as => 'hide', :via => [:get, :post]
end
