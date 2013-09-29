require File.expand_path('../../test_helper', __FILE__)

class MailMessageTest < ActiveSupport::TestCase
  fixtures :issues, :journals, :users, :projects
 
  # http://www.redmine.org/boards/3/topics/35164
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:mail_messages])


  context "method 'push_as_ccs'" do
    setup do
      @addrs = [ 'test1cc@example.com', 'test2cc@example.com']
      @message = MailMessage.find(1)
    end
    should "add mail_receiver" do
      @message.push_as_ccs( @addrs )
      @message.save!
      db_ccs = MailReceiver.find_all_by_mail_message_id_and_category(@message,'cc').collect{|a| a.receiver.mail }
      assert_equal  @addrs.sort, db_ccs.sort
    end
  end

  context "method 'ccs'" do
    setup do
      @addrs = [ 'test1cc@example.com', 'test2cc@example.com']
      @message = MailMessage.find(1)
      @message.push_as_ccs( @addrs )
      @message.save!
    end
    should "return mail_receiver" do
      ccs = @message.ccs.collect{|a| a.mail}
      assert_equal  @addrs.sort, ccs.sort
      @message.destroy
    end
  end

  context "method 'push_as_tos'" do
    setup do
      @addrs = [ 'test1to@example.com', 'test2to@example.com']
      @message = MailMessage.find(1)
    end
    should "add mail_receiver" do
      @message.push_as_tos( @addrs )
      @message.save!
      db_tos = MailReceiver.find_all_by_mail_message_id_and_category(@message,'to').collect{|a| a.receiver.mail }
      assert_equal  @addrs.sort, db_tos.sort
      @message.destroy
    end
  end

  context "method 'tos'" do
    setup do
      @addrs = [ 'test1to@example.com', 'test2to@example.com']
      @message = MailMessage.find(1)
      @message.push_as_tos( @addrs )
      @message.save!
    end
    should "return mail_receiver" do
      tos = @message.tos.collect{|a| a.mail}
      assert_equal  @addrs.sort, tos.sort
      @message.destroy
    end
  end

  context "method 'issue'" do
    context "of mailmessage which has issue" do
      setup do
	@mailmessage1=MailMessage.find(1)
      end
      should "return issue itself" do
	assert_equal Issue.find(2), @mailmessage1.issue 
      end
    end
    context "of mailmessage which has journal" do
      setup do
	@mailmessage2=MailMessage.find_by_id(2)
      end
      should "return parent issue of journal" do
	assert_equal Issue.find(1), @mailmessage2.issue 
      end
    end
  end

  context "method 'body'" do
    context "of mailmessage which has issue" do
      setup do
	@mailmessage1=MailMessage.find(1)
      end
      should "return desciption of issue" do
	assert_equal Issue.find(2).description, @mailmessage1.body 
      end
    end
    context "of mailmessage which has journal" do
      setup do
	@mailmessage2=MailMessage.find_by_id(2)
      end
      should "return notes of journal" do
	assert_equal Journal.find(2).notes, @mailmessage2.body 
      end
    end
  end

  context "a method 'reply_content'" do
    setup do
      @message = MailMessage.find(1)
    end
    should "return String" do
      ret = @message.reply_content 
      assert ret.is_a?(String) 
    end
  end
  context "a class_method 'find_by_ticket'" do
    setup do
      @message = MailMessage.find_by_ticket(Issue.find(2))
    end
    should "find" do
      assert @message.is_a?(MailMessage)
      assert_equal 1,@message.id
    end
  end
  context "a class_method 'destroy_from_issue'" do
    setup do
      @message = MailMessage.find(1)
      copy = @message.dup
      @issue = Issue.find(3)
      copy.save!
    end
    should "destroy" do
      MailMessage.destroy_from_issue(@issue)
      assert MailMessage.find_by_ticket_type_and_ticket_id('Issue',@issue.id).blank?
    end
  end
  context "a class_method 'destroy_from_journal'" do
    setup do
      @message = MailMessage.find(1)
      copy = @message.dup
      @journal = Journal.find(3)
      copy.save!
    end
    should "destroy" do
      MailMessage.destroy_from_journal(@journal)
      assert MailMessage.find_by_ticket_type_and_ticket_id('Journal',@journal.id).blank?
    end
  end
  context "a class_method 'destroy_from_project'" do
    setup do
      @message = MailMessage.find(1)
      copy = @message.dup
      @project = Project.find(2)
      copy.project = @project
      copy.save!
    end
    should "destroy" do
      MailMessage.destroy_from_project(@project)
      assert MailMessage.find_by_project_id(@project.id).blank?
    end
  end
  context "a class_method 'remove_reference_from_user'" do
    setup do
      @message = MailMessage.find(1)
      copy = @message.dup
      @user = User.find(3)
      copy.sender = @user
      copy.push_as_tos([@user.mail])
      copy.push_as_ccs([@user.mail])
      copy.save!
    end
    should "remove sender and destroy receiver" do
      before_count = MailReceiver.count("receiver_type = '#{@user.class.name}' AND receiver_id = #{@user.id}")
      MailMessage.remove_reference_from_user(@user)
      assert MailMessage.find_by_sender_id(@user.id).blank?
      assert_not_equal before_count, MailReceiver.count("receiver_type = '#{@user.class.name}' AND receiver_id = #{@user.id}")
    end
   
  end
private
end
