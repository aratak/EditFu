module ActionView
  module Helpers

    class FormBuilder

      def error_for(method, options = {})
        show_error self, @object, method, options
      end

      private
      
      def show_error form, object, column, options
        options[:css_class] = options[:css_class] || 'error'
        av = ActionView::Base.new(Rails::Configuration.new.view_path)
        av.render :text => form.error_message_on(column, options)
      end

    end
  end
end
