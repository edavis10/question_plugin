module QuestionPlugin
  module Patches
    module QueryPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
    
        base.send(:include, InstanceMethods)
        
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
    
          base.add_available_column(QueryColumn.new(:formatted_questions))
          
          alias_method_chain :available_filters, :question
          alias_method_chain :sql_for_field, :question
   
        end
      end
    
      module ClassMethods
        unless Query.respond_to?(:available_columns=)
          # Setter for +available_columns+ that isn't provided by the core.
          def available_columns=(v)
            self.available_columns = (v)
          end
        end
        
        unless Query.respond_to?(:add_available_column)
          # Method to add a column to the +available_columns+ that isn't provided by the core.
          def add_available_column(column)
            self.available_columns << (column)
          end
        end
      end
      
      module InstanceMethods
        # Wrapper around the +available_filters+ to add a new Question filter
        def available_filters_with_question
          return @available_filters if @available_filters
          available_filters_without_question
          
          if @available_filters["assigned_to_id"]
            user_values = @available_filters["assigned_to_id"][:values]
    
            @available_filters["question_assigned_to_id"] = { :name => l("question_text_assigned_to"), :type => :list_optional, :order => 16, :values => user_values }
            @available_filters["question_asked_by_id"] = { :name => l("question_text_asked_by"), :type => :list_optional, :order => 16, :values => user_values }
          end
          
          @available_filters
        end
        
        # Wrapper for +sql_for_field+ so Questions can use a different table than Issues
        def sql_for_field_with_question(field, operator, v, db_table, db_field, is_custom_filter=false)
          if field == "question_assigned_to_id" || field == "question_asked_by_id"
            v = values_for(field).clone
    
            db_table = Question.table_name
            if field == "question_assigned_to_id"
              db_field = 'assigned_to_id'
            else
              db_field = 'author_id'
            end
            
            # "me" value subsitution
            v.push(User.current.logged? ? User.current.id.to_s : "0") if v.delete("me")
            where_sql = []
            case operator
            when "="
              where_sql << "#{db_table}.#{db_field} in (?)"
            when "!"
              where_sql << "#{db_table}.#{db_field} not in (?)"
            when "!*"
              where_sql << "#{db_table}.#{db_field} is null"
#            when "*"
            end
            
            where_sql << "#{db_table}.opened = true"
            
            subselect_sql = Question.select("#{Journal.table_name}.journalized_id")
              .joins(:journal)
              .where(where_sql.join(' and '),[v.join(",")]).to_sql;
              
            sql = "#{Issue.table_name}.id in (#{subselect_sql})"
            
            return sql
          else
            return sql_for_field_without_question(field, operator, v, db_table, db_field, is_custom_filter)
          end
        end
      end  
    end
  end
end
