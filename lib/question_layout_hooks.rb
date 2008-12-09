class QuestionLayoutHooks < Redmine::Hook::ViewListener
  
  # Add a question CSS class
  def view_layouts_base_html_head(context = { })
    o = <<CSS
  <style type="text/css">
.question { background-color:#FFEBC1; border:2px solid #FDBD3B; margin-bottom:12px; padding:0px 4px 8px 4px; }
td.formatted_questions { text-align: left; white-space: normal}
td.formatted_questions ol { margin: 0px }
  </style>
CSS
    return o
  end
end
