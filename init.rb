Redmine::Plugin.register :redmine_mail_dispatch_ext do
  name 'Redmine Mail Dispatch Ext plugin'
  author 'Akira Sato'
  description 'This is a plugin for Redmine Mail Dispatch Extention'
  version '0.0.1'
  url 'https://github.com/a3suger/redmine_mail_dispatch_ext'
  author_url 'https://github.com/a3suger'

project_module :mail_messages do
  permission :view_mail_messages, :mail_messages =>[:index,:show]
  permission :send_mail_messages, :mail_messages =>[:new_reply,:send_reply,:new_mail,:send_mail]
end

menu :project_menu, :mail_message,
	{ :controller => 'mail_messages', :action => 'index'},
	:last => true, :param => :project_id 

activity_provider :mail_messages, :class_name => 'MailMessage'

require_dependency 'mail_dispatch/view_hooks'

end

require_dependency 'application_helper_patch'

require_dependency 'mail_handler_patch'

Rails.configuration.to_prepare do
  MailHandler.send(:include, MailHandlerPatch)  
end


