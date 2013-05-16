if Rails::VERSION::MAJOR < 3
  ActionController::Routing::Routes.draw do |map|
	map.connect 'questions/autocomplete_for_user_login/project/:id/issue/:issue_id', :controller=> 'questions', :action=> 'autocomplete_for_user_login'
	map.connect 'questions/my_issue_filter(/project/:project)' ,:controller=> 'questions', :action=> 'my_issue_filter'
	map.connect 'questions/user_issue_filter/user/:user_id' ,:controller=> 'questions', :action=> 'user_issue_filter'
  end
else
	match 'questions/autocomplete_for_user_login/project/:id/issue/:issue_id' => 'questions#autocomplete_for_user_login', :format => false, :as => 'questions_autocomplete_for_user_login'
	match 'questions/my_issue_filter(/project/:project)' => 'questions#my_issue_filter', :format => false, :as => 'questions_my_issue_filter'
	match 'questions/user_issue_filter/user/:user_id' => 'questions#user_issue_filter', :format => false, :as => 'questions_user_issue_filter'
end

