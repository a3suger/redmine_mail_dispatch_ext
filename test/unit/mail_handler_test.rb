require File.expand_path('../../test_helper', __FILE__)

#MailHandler.send(:include, MailHandlerPatch)  


class MailHandlerTest < ActiveSupport::TestCase
  fixtures :users, :projects, :enabled_modules, :roles,
           :members, :member_roles, :users,
           :issues, :issue_statuses,
           :workflows, :trackers, :projects_trackers,
           :versions, :enumerations, :issue_categories,
           :custom_fields, :custom_fields_trackers, :custom_fields_projects,
           :boards, :messages

  # http://www.redmine.org/boards/3/topics/35164
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:mail_messages])


  FIXTURES_PATH = File.dirname(__FILE__) + '/../../test/fixtures/mail_handler'

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events.delete('issue_added') 
    Setting.notified_events.delete('issue_updated') 
    @options = { :issue => {} }
    @options[:issue][:project] = 'ecookbook' #id : 1
    @options[:issue][:status]  = 'New' #id : 1
    @options[:issue][:tracker] = 'Bug' #id : 1
    @options[:unknown_user]    = 'accept' 
    @options[:no_permission_check] = '1' 
    @options[:allow_override]='project,status,tracker' 
  end

  def teardown
    Setting.clear_cache
  end

  context "Receiving a new mail" do
    context "from the non-exist user" do
      setup do
        @issue,@mm = submit_email('simple.eml',@options)
      end
      should "make a new issue and make a new mail user" do
        assert_issue_created(@issue,@mm)
        assert_equal User.anonymous, @mm.sender
        assert @mm.mail_user.present?
        assert_equal 'test1@example.org', @mm.sender_addr,"sender"
        assert_include_mail 'meeting@example.org',@mm.tos,"to"
        assert_include_mail 'boss@example.com',@mm.ccs,"cc"
      end
      teardown do
        @mm.destroy unless @mm.nil?
      end
    end
    context "from the exist user" do
      setup do
        @issue,@mm = submit_email('simple_exist_user.eml',@options)
      end
      should "make a new issue without making a mail user" do
        assert_issue_created(@issue,@mm)
        assert @mm.sender.present?
        assert @mm.mail_user.nil?
        assert_equal 'rhill@somenet.foo', @mm.sender_addr
        assert_include_mail 'meeting@example.org',@mm.tos,"to"
      end
      teardown do
        @mm.destroy unless @mm.nil?
      end
    end
  end

  context "Receiving reply mail" do
    setup do
      @issue1,@mm1 = submit_email('simple.eml',@options)
      @issue2,@mm2 = submit_email('reply.eml',@options)
      @issue3,@mm3 = submit_email('re-reply.eml',@options)
      @issue4,@mm4 = submit_email('refference.eml',@options)
    end
    context "of issue" do
      should "make journal" do
        assert_journal_created @issue2,@mm2
        assert_equal @mm1, @mm2.parent,'A parent of new mail_message is the existing mail_message'
      end
    end
    context "of journal" do
      should "make journal" do
        assert_journal_created @issue3,@mm3
        assert_equal @mm2, @mm3.parent,'A parent of new mail_message is the existing mail_message'
      end
    end
    context "of journal without in_reply_to header" do
      should "make journal" do
        assert_journal_created @issue4,@mm4
        assert_equal @mm1, @mm4.parent,'A parent of new mail_message is the existing mail_message'
      end
    end
    context "of issue which is closed" do
      setup do
	 @mm1.ticket = Issue.find(8) # issue-8 is closed
	 @mm1.save!
         @mm2.delete
         @issue2,@mm2 = submit_email('reply.eml',@options)
      end
      should "make issue" do
        assert_issue_created(@issue2,@mm2)
        assert_equal @mm1, @mm2.parent,'A parent of new mail_message is the existing mail_message'
      end
    end
    teardown do
      @mm4.destroy unless @mm4.nil?
      @mm3.destroy unless @mm3.nil?
      @mm2.destroy unless @mm2.nil?
      @mm1.destroy unless @mm1.nil?
    end
  end  
  context "Receiveng a recieved mail(duplicate)" do
    setup do
      @issue1,@mm1 = submit_email('simple.eml',@options)
      @issue2,@mm2 = submit_email('simple.eml',@options)
    end
    should "not make anything" do
      assert !@issue2, 'An issue is expected fauls'
    end
    teardown do
      @mm2.destroy unless @mm2.nil?
      @mm1.destroy unless @mm1.nil?
    end
  end
#   def test_add_reply_closed_issue
#     ActionMailer::Base.deliveries.clear
# #    @options[:issue][:status]  = 'Closed' #id : 1
#     issue1 = submit_email('simple.eml',@options)
#     issue1.status_id = 5 
#     issue1.save!
# #    @options[:issue][:status]  = 'New' #id : 1
#     issue2 = submit_email('reply.eml',@options)
#     assert_issue_created(issue2)
#     assert_equal issue1.id, issue2.parent_id
#   end
# 
#   def test_extra_header_simple
#     ActionMailer::Base.deliveries.clear
#     issue1 = submit_email('simple_extra_header.eml',@options)
#     p issue1
#     assert_equal 3, issue1.tracker_id
#   end
# 
#   def test_extra_header
#     WorkflowTransition.delete_all
#     WorkflowTransition.create!(:role_id => 1, :tracker_id => 1,
#                                :old_status_id => 1, :new_status_id => 2,
#                                :author => false, :assignee => false)
#     WorkflowTransition.create!(:role_id => 1, :tracker_id => 1,
#                                :old_status_id => 1, :new_status_id => 3,
#                                :author => true, :assignee => false)
#     WorkflowTransition.create!(:role_id => 1, :tracker_id => 1, :old_status_id => 1,
#                                :new_status_id => 4, :author => false,
#                                :assignee => true)
#     WorkflowTransition.create!(:role_id => 1, :tracker_id => 1,
#                                :old_status_id => 1, :new_status_id => 5,
#                                :author => true, :assignee => true)
#  
#     ActionMailer::Base.deliveries.clear
#     issue1 = submit_email('simple.eml',@options)
#     issue2 = submit_email('reply_extra_header.eml',@options)
#     p issue2
#     assert_equal 5, issue1.status_id
#   end

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    yield raw if block_given?
    ticket  = MailHandler.receive(raw, options)
    message = MailMessage.find_by_ticket(ticket) unless ticket.blank?
    return ticket,message
  end

  def assert_include_mail(mail,array,msg)
    ret = false
    if array.is_a?(Array)
      array.each{|a|
	 ret = true if a.mail == mail
      }
    end
    assert ret,"#{mail} is expected in an array of #{msg}."
  end

  def assert_issue_created(issue,mail_message=nil)
    assert issue.is_a?(Issue), 'A class of issue is expected Issue (in assert_issue_created)'
    assert !issue.new_record?, 'The issue is not expected new_record (in assert_issue_created)'
    issue.reload
    assert !mail_message.nil?, 'A instance of MailMessage is stored ( in assert_journal_created)'
  end

  def assert_journal_created(journal,mail_message=nil)
    assert journal.is_a?(Journal), 'A class of journal is expected Journal (in assert_journal_created)'
    assert !journal.new_record?, 'The journal is not expected new_record (in assert_journal_created)'
    journal.reload
    assert !mail_message.nil?, 'A instance of MailMessage is stored ( in assert_journal_created)'
  end
end
