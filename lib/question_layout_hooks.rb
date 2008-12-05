class QuestionLayoutHooks < Redmine::Hook::ViewListener
  
  # Add a question CSS class
  def view_layouts_base_html_head(context = { })
    o = <<CSS
  <style type="text/css">
.question { background-color:#FFEBC1; border:2px solid #FDBD3B; margin-bottom:12px; padding:0px 4px 8px 4px; }
  </style>
CSS
    return o
  end
end
