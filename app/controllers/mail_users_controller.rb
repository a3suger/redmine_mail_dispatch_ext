class MailUsersController < ApplicationController
  unloadable
  
#  before_filter :authorize
#  before_filter :find_project
  before_filter :require_admin, :except => [:index,:show]
#  before_filter :authorize, :only => [:index,:show]
  before_filter :require_permission, :only => [:index,:show]
  before_filter :find_mail_user, :except => [:index,:new,:create]

  helper :mail_messages
  helper :sort
  include SortHelper

  def index
    sort_init 'id'
    sort_update %w(id mail)

    if User.current.admin?
      @mail_users = MailUser.find(:all,:order => sort_clause)
    else
      @mail_messages = MailMessage.where(["project_id IN (?)",@projects])
      @mail_users = MailUser.where(["id IN (?)",@mail_messages.collect{|message| message.mail_user}]).order(sort_clause)
    end
    @mail_user  = MailUser.new
  end

  def new
    @mail_user = MailUser.new
  end

  def create
    @mail_user = MailUser.new 
    @mail_user.attributes = params[:mail_user]
    if @mail_user.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def show
    sort_init 'date','desc'
    sort_update %w(id subject date)

    @mail_messages = MailMessage.where(["project_id IN (?) and mail_user_id IN (?)",@projects,@mail_user]).order(sort_clause)
  end

  def edit
  end

  def update
    @mail_user.attributes = params[:mail_user]
    if (request.post? || request.put?) && @mail_user.save 
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :id => @mail_user 
    else
      render :action => 'edit'
    end
  end

  def destroy
    @mail_user.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to :action => 'index'
  end

private

  def require_permission
    return if User.current.admin?
    render_403 if User.current == User.anonymous
    @projects = User.current.projects_by_role.values.flatten.uniq
    unless @projects.nil?
      @projects.select! do |project|
        User.current.allowed_to?({:controller => 'mail_messages', :action => 'show'} ,project)
      end
    end
    render_403 if @projects.nil?
  end

  def find_mail_user
    @mail_user = MailUser.find_by_id(params[:id])
    render_404 if @mail_user.nil?
  end

end
