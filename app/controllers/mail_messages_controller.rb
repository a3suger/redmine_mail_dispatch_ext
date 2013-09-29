class MailMessagesController < ApplicationController
  unloadable
  menu_item :mail_message
  before_filter :find_project_by_project_id # in application_controller.rb 
  before_filter :authorize
  before_filter :find_mail_message, :only => [:show,:new_reply,:send_reply]

  helper :sort
  include SortHelper

  def index
    sort_init 'id','asc'
    sort_update %w(id subject date)

    @limit = per_page_option
    @mail_message_count = MailMessage.where("project_id = ?",@project.id).count
    @mail_message_pages = Paginator.new self, @mail_message_count, @limit, params['page']
    @mail_messages = MailMessage.where( "project_id = ?",@project.id).limit(@mail_message_pages.items_per_page).offset(@mail_message_pages.current.offset).order(sort_clause)
  end

  def show
    respond_to do |format|
      format.html { 
	 if params[:short]=='1' then 
	    render partial: 'show'
	 else
	    render :layout => !request.xhr? 
	 end
      }
	 
    end
  end

  def new_reply
    respond_to do |format|
      format.html { render :action => 'new_mail',:layout => !request.xhr? }
    end
  end

  def new_mail
    @mail_message = MailMessage.new
    respond_to do |format|
      format.html { render :layout => !request.xhr?  }
    end
  end

  def send_reply
    send_mail
  end

  def send_mail
    sender_param =  {:project_id => params[:project_id]}
    sender_param[:mailmessage] = @mail_message unless @mail_message.nil?
    sender_param[:subject] = params[:subject] unless params[:subject].nil?
    sender_param[:body] = params[:body] unless params[:body].nil?

    # copy params to sender_param 'to','cc','bcc'
    if !params[:addr].nil? && !params[:category].nil?
      params[:addr].each do |key,addr|
        next if addr.blank? 
	s_key = params[:category].fetch(key).to_sym
        if sender_param[s_key].nil?  
          sender_param[s_key] = [addr]
	else
          sender_param[s_key] << addr
	end
      end
    end

    email = MailSender.send_mail(sender_param)
    if email.is_a?(ActionMailer::Base::NullMail)
       flash[:alert] = l(:notice_email_error,{value: "make mail message"})
    else
#       email.deliver
       flash[:notice] = l(:notice_email_send,{value: ""})
    end
    redirect_to :action => 'index'
  end

private

  def find_mail_message
    @mail_message = MailMessage.find_by_id_and_project_id(params[:id],@project.id)
    render_404 if @mail_message.nil?
  end
end
