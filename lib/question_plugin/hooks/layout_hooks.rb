module QuestionPlugin
  module Hooks
    class LayoutHooks < Redmine::Hook::ViewListener
      
      # Add a question CSS class
      def view_layouts_base_html_head(context = { })
      o = <<CSS
  <style type="text/css">

.question, div.flash.question { background-color:#FFEBC1; border:2px solid; margin-bottom:12px; padding:0px 4px 8px 4px; border-color: #fdbd2b}
.question-line { float: right; }
td.formatted_questions { text-align: left; white-space: normal}
td.formatted_questions ol { margin-top: 0px; margin-bottom: 0px; }

.kanban-question { background:#FFFFFF none repeat scroll 0 0; border:1px solid #D5D5D5; padding:2px; font-size: 0.8em }
.question-link {font-weight: bold; } /* Kanban Menu item */

  </style>
CSS
        return o
      end
    end
  end
end
