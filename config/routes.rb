
ActionController::Routing::Routes.draw do |map|
    map.connect 'questions/:action/:id', :controller => 'questions'
end
