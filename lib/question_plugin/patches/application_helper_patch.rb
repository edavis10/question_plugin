module QuestionPlugin
  module Patches
    module ApplicationHelperPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method_chain :render_flash_messages, :question
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def render_flash_messages_with_question
          s = "" 
          s = render :partial => 'layouts/questions', :layout => false unless Setting.plugin_question_plugin[:show_banner] != "1"
          s << render_flash_messages_without_question
          s.html_safe
        end
      end
    end
  end
end
