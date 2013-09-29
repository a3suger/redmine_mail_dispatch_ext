class MailUser < ActiveRecord::Base
  unloadable
 
  # rfc 5321 section 4.5.3.1.3
  MAIL_LENGTH_LIMIT = 256

  validates_presence_of :mail
  validates_uniqueness_of :mail,  :case_sensitive => false
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true
  validates_length_of :mail, :maximum => MAIL_LENGTH_LIMIT, :allow_nil => false
  
  before_destroy :remove_reference_from
  def self.append_by_mail(mail)
    find_by_mail(mail) || create!(:mail => mail)
  end

private

  def remove_reference_from
    MailMessage.remove_reference_from_user(self)
  end
  
end
