require File.expand_path('../../test_helper', __FILE__)

class MailReceiverTest < ActiveSupport::TestCase
  fixtures :users

  context "a class-method 'destroy_from'" do
    setup do
      @mailuser = MailUser.create(:mail => 'foo@example.com')
      @user      = User.find(1)
      @receiver1 = MailReceiver.create(:receiver => @mailuser, :category => 'to')
      @receiver2 = MailReceiver.create(:receiver => @user, :category => 'to')
    end
    context " using user" do
      should "delete" do
	MailReceiver.destroy_from(@user)
	assert MailReceiver.find_by_receiver_type_and_receiver_id(@user.class.name,@user.id).blank? 
      end
    end
    context " using mailuser" do
      should "delete" do
	MailReceiver.destroy_from(@mailuser)
	assert MailReceiver.find_by_receiver_type_and_receiver_id(@mailuser.class.name,@mailuser.id).blank? 
      end
    end
  end
end
