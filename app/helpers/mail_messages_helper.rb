module MailMessagesHelper
  def make_reply_content( )
	  return "" if @mail_message.body.nil? 
	  return "" if @mail_message.sender.nil? 
	  content = "#{ll(Setting.default_language, :text_user_wrote, @mail_message.sender_addr)}\n> " 
	  content << @mail_message.body.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]').gsub(/(\r?\n|\r\n?)/, "\n> ") + "\n\n"
  end

  def make_reply_subject( )
	  return "" if @mail_message.subject.nil?
	  return "" if @mail_message.sender.nil? 
	  "Re: #{@mail_message.subject}"
  end

  def send_mail_or_reply_path 
	  if @mail_message.id.nil? 
		  verb = "send_mail"
	  else
		  verb = "#{@mail_message.id}/send_reply"
	  end
	  "#{project_path(@project)}/mail_messages/#{verb}"
  end

  def make_hidden_id
	  return "" if @mail_message.id.nil?
	  "<input type=\"hidden\" name=\"id\" value=\"#{@mail_message.id}\" />"
  end

  def link_to_ticket(mailmessage)
    case mailmessage.ticket_type
    when 'Issue'
      link_to "#{mailmessage.issue.tracker.name} ##{mailmessage.issue.id} (#{mailmessage.issue.status})",{:controller => 'issues', :action => 'show', :id => mailmessage.issue.id}
    when 'Journal'
      link_to "#{mailmessage.issue.tracker.name} ##{mailmessage.issue.id} (#{mailmessage.issue.status}) change-##{mailmessage.ticket_id}",{:controller => 'issues', :action => 'show', :id => mailmessage.issue.id,:anchor => "change-#{mailmessage.ticket_id}"}
    end
  end

  def link_to_sender(mailmessage)
    if mailmessage.sender == User.anonymous
      link_to h(mailmessage.sender_addr), mail_user_path(mailmessage.mail_user)
    else
      link_to_user mailmessage.sender
    end
  end
  
  def link_to_activity(mailmessage)
    link_to format_time(mailmessage.date),{:controller => 'activities', :action => 'index', :id => mailmessage.project, :user_id => nil, :from => mailmessage.date.to_date}
  end

  def link_to_mailmessage(mailmessage)
    link_to h(mailmessage.subject), project_mail_message_path(mailmessage.project,mailmessage)
  end
end


