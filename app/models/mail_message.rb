class MailMessage < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :parent, :class_name => "MailMessage"
  belongs_to :sender, :class_name => "User"
  belongs_to :mail_user
  belongs_to :ticket, :polymorphic => true
  has_many :receivers, :class_name => "MailReceiver", :autosave =>true, :dependent => :destroy

  acts_as_event :title => Proc.new{|o| "Mail ##{o.id} (#{o.sender_addr}) #{o.subject}" },
	       :description => :body,
	       :datetime => :date,
	       :url => Proc.new{|o| {:controller => 'mail_messages', :action => 'show', :id => o.id, :project_id => o.project_id }},
	       :author => :sender
  acts_as_activity_provider :type => 'mail_messages',
	       :timestamp =>  "#{MailMessage.table_name}.date",
	       :author_key => "#{MailMessage.table_name}.sender_id",
	       :permission => :view_mail_messages,
	       :find_options => {:joins => :project}

#  validate_presense :subject,:date,:messageid,:ticket,:project

  before_destroy :remove_childlen_reference

  def push_as_ccs( addrs ) # addrs:Array
     append_receiver( addrs , 'cc') 
  end

  def push_as_tos( addrs ) # addrs:Array
     append_receiver( addrs , 'to') 
  end

  def ccs 
     _cc = Array.new
     receivers.each do |a|
       _cc<<a.receiver if a.category == 'cc' 
     end
     _cc
  end

  def tos
     _to = Array.new
     receivers.each do |a|
        _to<<a.receiver if a.category == 'to'
     end
     _to
  end

  def sender_addr
    if sender == User.anonymous 
       mail_user.mail
    else
       sender.mail
    end
  end

  def issue
    case ticket_type
    when 'Issue'
      ticket
    when 'Journal'
      ticket.issue
    else
      nil
    end
  end

  def body 
    case ticket_type 
    when 'Issue'
      ticket.description
    when 'Journal'
      ticket.notes
    else
      ''
    end
  end

  def reply_content
    # Replaces pre blocks with [...]
     _text = body.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]')
     @reply_content = "#{ll(Setting.default_language, :text_user_wrote, sender_addr)}\n> "
     @reply_content << _text.gsub(/(\r?\n|\r\n?)/, "\n> ") + "\n\n"
  end

  def self.find_by_ticket(ticket)
    self.find_by_ticket_type_and_ticket_id(ticket.class.name,ticket.id)
  end

  def self.destroy_from_issue(issue)
    if !issue.nil? && issue.is_a?(Issue) 
      MailMessage.destroy_all(["ticket_type = 'Issue' AND ticket_id = ?",issue.id])
    end 
  end

  def self.destroy_from_journal(journal)
    if !journal.nil? && journal.is_a?(Journal) 
      MailMessage.destroy_all(["ticket_type = 'Journal' AND ticket_id = ?",journal.id])
    end 
  end

  def self.destroy_from_project(project)
    if !project.nil? && project.is_a?(Project) 
      MailMessage.destroy_all(["project_id = ?",project.id])
    end 
  end

  def self.remove_reference_from_user(user)
    if !user.nil?  
      if user.is_a?(User) 
         MailMessage.update_all(["sender_id = null"],["sender_id = ?",user.id])
      else user.is_a?(MailUser)
         MailMessage.update_all(["mail_user_id = null"],["mail_user_id = ?",user.id])
      end
      MailReceiver.destroy_from(user)
    end 
  end

private
  def append_receiver(addrs,cat)
    return if addrs == nil
    addrs.flatten.compact.uniq.collect{|a|
      addr = a.strip.downcase
      user = User.find_by_mail(addr) || MailUser.append_by_mail(addr)
      receivers.build(
        :receiver_type => user.class.name,
	:receiver_id   => user.id,
        :category => cat
      )
    }
  end
  #
  # no good  :: receivers.build(:receiver => user, ....) 
  #
  def remove_childlen_reference 
     childlen = self.class.find_all_by_parent_id(self.id)
     if !childlen.blank?
       childlen.each do |child|
	 child.parent_id=nil
	 child.save!(:validation => false)
       end
     end
  end

end
