module QuestionActiveRecordRelationPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method :count_before_question, :count
      alias_method :sum_before_question, :sum
      alias_method :find_before_question, :find
      alias_method :all_before_question, :all
      alias_method :find_ids_before_question, :find_ids

      # Override ActiveRecord::Calculations.count
      def count(*args)
        scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
        count_before_question(*args)
      end

      # Override ActiveRecord::Calculations.sum
      def sum(*args)
        scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
        sum_before_question(*args)
      end

      # Override ActiveRecord::FinderMethods.find
      def find(*args)
        scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
        find_before_question(*args)
      end

      # Override ActiveRecord::FinderMethods.all
      def all(*args)
        scan_for_options_hash_and_add_includes_if_needed(self.klass, args)
        all_before_question(*args)
      end

      # Override ActiveRecord::FinderMethods.find_ids
      def find_ids(*args)
        relation = scan_where_clauses_and_add_includes_if_needed
        relation.find_ids_before_question(*args)
      end

      private

      def scan_where_clauses_and_add_includes_if_needed
        relation = self
        # Ensure passed class inherits from the Issue class
        if relation.klass <= Issue
          @where_values.each do |where_value|
            if where_value.is_a?(String) && where_value.include?('question')
              relation = relation.includes(:questions)
            elsif where_value.is_a?(Array) && where_value[0].include?('question')
              relation = relation.includes(:questions)
            end
          end
        end
        relation
      end

      def scan_for_options_hash_and_add_includes_if_needed(klass, args)
        # Ensure passed class inherits from the Issue class
        if klass <= Issue
          args.each do |arg|
            if arg.is_a?(Hash) && arg[:conditions]
              if arg[:conditions].is_a?(String) && arg[:conditions].include?('question')
                # String conditions
                add_questions_to_the_includes(arg)
              elsif arg[:conditions].is_a?(Array) && arg[:conditions][0].include?('question')
                # Array conditions
                add_questions_to_the_includes(arg)
              end
            end
          end
        end
      end

      def add_questions_to_the_includes(arg)
        if arg[:include]
          # Has includes
          if arg[:include].is_a?(Hash) || arg[:include].is_a?(Array)
            # Hash includes
            arg[:include] << :questions
          else
            # single includes
            arg[:include] = [ arg[:include] , :questions ]
          end
        else
          # No includes
          arg[:include] = :questions
        end
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
