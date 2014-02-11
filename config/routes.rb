if Rails::VERSION::MAJOR < 3
  ActionController::Routing::Routes.draw do |map|
	map.connect 'issuequestions/autocomplete_for_user_login/project/:id/issue/:issue_id', :controller=> 'issuequestions', :action=> 'autocomplete_for_user_login'
	map.connect 'issuequestions/my_issue_filter(/project/:project)' ,:controller=> 'issuequestions', :action=> 'my_issue_filter'
	map.connect 'issuequestions/user_issue_filter/user/:user_id' ,:controller=> 'issuequestions', :action=> 'user_issue_filter'
  end
else
	match 'issuequestions/autocomplete_for_user_login/project/:id/issue/:issue_id' => 'issuequestions#autocomplete_for_user_login', :format => false, :as => 'issuequestions_autocomplete_for_user_login'
	match 'issuequestions/my_issue_filter(/project/:project)' => 'issuequestions#my_issue_filter', :format => false, :as => 'questions_my_issue_filter'
	match 'issuequestions/user_issue_filter/user/:user_id' => 'issuequestions#user_issue_filter', :format => false, :as => 'questions_user_issue_filter'
end

