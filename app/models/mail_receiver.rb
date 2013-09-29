class MailReceiver < ActiveRecord::Base
  unloadable
  belongs_to :mail_message
  belongs_to :receiver, :polymorphic => true 

  validates :category, inclusion: { in: %(to cc bcc), message: "%{value} is not a valid category." }

  def self.destroy_from(user)
    if !user.nil? 
      self.destroy_all(["receiver_type = ? AND receiver_id = ?",user.class.name, user.id])
    end 
  end 
end
