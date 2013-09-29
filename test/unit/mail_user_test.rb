require File.expand_path('../../test_helper', __FILE__)

class MailUserTest < ActiveSupport::TestCase

  context "a class-method 'append_by_mail'" do
    setup do
       @mailuser = MailUser.create!(:mail => 'test@example.com')
    end
    context "using exist mail" do
      should "not append" do
        mail_user = MailUser.append_by_mail(@mailuser.mail)
        assert_equal @mailuser,mail_user
      end
    end
    context "using mail (not exist)" do
      should "append" do
        mail = 'foo@example.com'
        mail_user = MailUser.append_by_mail(mail)
        assert mail_user.is_a?(MailUser)
	assert_not_equal mail_user,@mailuser
        assert_equal mail,mail_user.mail
      end
    end
  end
  context "method destory" do
    setup do
       @mailuser = MailUser.create!(:mail => 'test@example.com')
    end
    should "destroy" do
       id = @mailuser.id 
       MailUser.destroy(id)
       assert MailUser.find_by_id(id).nil? 
    end
  end
end
