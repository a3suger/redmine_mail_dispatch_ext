module MailDispatch
  class ViewHooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      return %{
         #{javascript_include_tag 'send_mail', :plugin => 'redmine_mail_dispatch_ext'}
      }
    end

    def view_issues_show_description_bottom(context={})
      project = context[:project]
      issue   = context[:issue]
      mail_message = MailMessage.find_by_project_id_and_ticket_type_and_ticket_id(project.id,'Issue',issue.id)
      return '' if mail_message.nil?
      context[:controller].send(:render_to_string, {
         :partial => 'mail_messages/issue_extention',
	 :locals => {:mail_message => mail_message } 
      })
    end

    def view_issues_history_journal_bottom(context={})
      project = context[:project]
      journal = context[:journal]
      mail_message = MailMessage.find_by_project_id_and_ticket_type_and_ticket_id(project.id,'Journal',journal.id)
      return '' if mail_message.nil?
      context[:controller].send(:render_to_string, {
         :partial => 'mail_messages/issue_extention',
	 :locals => {:mail_message => mail_message } 
      })
    end

  end
end
