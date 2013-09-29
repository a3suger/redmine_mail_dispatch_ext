require_dependency 'mail_handler'
require_dependency 'mail_message'
require 'mail-iso-2022-jp'

module MailHandlerPatch

  def self.included(base)
    base.send(:include, MailHandlerExtendMethods)

    base.class_eval do
      alias_method_chain :dispatch_to_default, :ext
      alias_method_chain :plain_text_body, :ext
    
     def self.original_project
       @@original_project
     end

      def self.receive_with_ext(email,options={})
	@@original_project = nil 
	@@original_project = Project.find_by_identifier(options[:issue][:project]) unless options[:issue].nil?

	if options == {} 
	   copyed_options = options
	else
	   copyed_options = options.dup
	   copyed_options[:issue] = options[:issue].dup unless options[:issue].nil?
	end
        self.receive_without_ext(email,copyed_options)
      end

      class << self
        alias_method_chain :receive, :ext
      end
    end
  end


  module MailHandlerExtendMethods

   
    # This method is a string which is log message if ignore
    def check_to_ignore
      message_id = email.message_id
      parent = MailMessage.find_by_messageid_and_project_id(message_id,@project.id) if message_id.present? && !@project.nil?
      return "MailHandlerExt : ignorging email of which message_id is same as received email[#{parent.id}]" if parent

      return false
    end

    def check_extra_header
      %w(Project Tracker Status).each do |key|
	header_name ="X-Redmine-Override-#{key}" 
        if !email.header[header_name].nil? 
	  value = email.header[header_name].value
	  if @extra_text_body.nil?
	    @extra_text_body = "#{key}: #{value}\n" 
	  else
	    @extra_text_body << "#{key}: #{value}\n" 
	  end
	end
      end
    end
    
    def dispatch_to_default_with_ext
      @project = self.class.original_project
      # check to gnore emails  
      if str = check_to_ignore
	if logger && logger.info
	  logger.info str 
	end
	return false
      end
      
      check_extra_header 
      
      # dispatch

      parent = nil
      unless  @project.nil?
        [email.in_reply_to,email.references].flatten.compact.each { |m_id|
           break if parent = MailMessage.find_by_messageid_and_project_id(m_id,@project.id)
        }
      end
      if !parent.nil? then
	if parent.issue && parent.issue.closed?  then
	  ret = dispatch_to_default_without_ext 
	  if ret.is_a?(Issue)
	    ret.parent_issue_id = parent.issue.id 
	    ret.save!
	  end
	else
	  method_name ="receive_#{parent.ticket_type.downcase}_reply"
	  ret = send method_name, parent.ticket_id
	end
      else
	ret = dispatch_to_default_without_ext 
      end
      return ret until ret 


      # recored
      message = MailMessage.new 
      message.messageid = email.message_id
      message.project   = @project
      message.subject   = email.subject.to_s
      message.date      = DateTime.parse email.date.to_s
      message.ticket    = ret
      message.parent    = parent if defined?( parent )
      message.sender    = user
      if user == User.anonymous 
	 message.mail_user = MailUser.append_by_mail(email.from.to_a.first.to_s.strip)
      end
      # to 
      message.push_as_tos(email.to)
      # cc
      message.push_as_ccs(email.cc)
      message.save!
      # return 
      message.ticket
    end

#    alias_method_chain :dispatch_to_default, :ext
  end

  def plain_text_body_with_ext
    return @plain_text_body unless @plain_text_body.nil?
    plain_text_body_without_ext 
    unless @extra_text_body.nil?
      @plain_text_body.concat("\n") 
      @plain_text_body.concat(@extra_text_body) 
      p @plain_text_body
    end
    @plain_text_body
  end

end
