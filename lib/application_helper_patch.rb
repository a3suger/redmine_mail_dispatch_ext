require_dependency 'application_helper'

module ApplicationHelperPatch
  def self.included(base)
#   base.send(:include, InstanceMethod)
    
    base.class_eval do
      def link_to_show_area(cname,target,label,options={})
        @area_javascript ||= {}
        @area_javascript[cname] = "$('a.#{cname}').on('ajax:success',function(data,status,xhr){$('#inner_#{target}').html(status);showAndScrollTo('#{target}','');})"
        link_to_if_authorized( label,options,:remote => true, 'date-type' => 'html', :class => cname )
      end

      def string_of_javascript_for_area
        ret = ""
        unless @area_javascript.nil?
          ret = @area_javascript.values.join("\n")+";"
          @area_javascript = {}
        end
        ret 
      end

      def area_tag(id)
        area = content_tag(:div, :id => id, :style => "display:none;") do
          content_tag(:div ,:class =>"contextual" )do 
            link_to l(:button_cancel), "#", :onclick => "$('##{id}').hide();return false;".html_safe 
          end + content_tag(:div,"", :id => "inner_#{id}")
        end
        area << javascript_tag( string_of_javascript_for_area )
        area
      end

    end

  end

  module InstanceMethod
  end
end

ApplicationHelper.send(:include, ApplicationHelperPatch)



