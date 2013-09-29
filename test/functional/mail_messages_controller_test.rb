require File.expand_path('../../test_helper', __FILE__)

require 'shoulda'
#
# We must override a method 'allowed_to?' of User
# in order to test the controller  with 'before_filter authorize.'
#
require 'user'
class User < Principal
  def allowed_to?(action, context, options={}, &block)
    true
  end
end

class MailMessagesControllerTest < ActionController::TestCase
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries

 
  # http://www.redmine.org/boards/3/topics/35164
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',  
	[:mail_messages])

  context "#index" do
    setup do
        make_param 	
    end
    context "with exist project_id" do 
      should "respond success, render index template, and include table tag" do 
        get( :index, @request_params,@session_params )
        assert_response :success
        assert_template 'index'
        assert_tag :tag => 'table'
      end
    end
    context "with project which has no messages" do 
      setup do
        @request_params = {:project_id => 2}
      end
      should "respond success, render index template, and include no table tag" do 
        get( :index, @request_params,@session_params )
        assert_response :success
        assert_template 'index'
        assert_no_tag :tag => 'table'
      end
    end
  end

  context "#show" do
    context "with exist id" do 
      setup do
        make_param_with_exist_id
      end
      should "respond success, and render show template" do 
        get( :show, @request_params,@session_params )
        assert_response :success
        assert_template 'show'
      end
    end
    context "with bad id" do 
      setup do
        make_param_with_bad_id
      end
      should "respond 404" do
        get( :show, @request_params,@session_params )
        assert_response 404
      end
    end
  end

  context "#new_mail" do
    setup do
      make_param
    end
    should "respond success and render write template" do
      get( :new_mail, @request_params,@session_params )
      assert_response :success
      assert_template 'write'
    end
  end

  context "#send_mail" do
    context "with to" do
      setup do
        make_param
	add_param_to_to
        post( :send_mail, @request_params,@session_params )
      end
      should "be redirected index with notice without alter" do
	assert_respond_with_notice
      end
    end
    context "without to" do
      setup do
        make_param
        post( :send_mail, @request_params,@session_params )
      end
      should "be redirected index with alert without notice" do
	assert_respond_with_alert
      end
    end
  end

  context "#new_reply" do
    context "with exist id" do 
      setup do
        make_param_with_exist_id
      end
      should "respond success and render write template" do
        get( :new_reply, @request_params,@session_params )
        assert_response :success
        assert_template 'write'
      end
    end
    context "with bad id" do 
      setup do
        make_param_with_bad_id
      end
      should "respond 404" do
        get( :new_reply, @request_params,@session_params )
        assert_response 404
      end
    end
  end

  context "#send_reply" do
    context "with exist id" do 
      context "with to" do
        setup do
          make_param_with_exist_id
          add_param_to_to
          post( :send_reply, @request_params,@session_params )
        end
	should "be redirected index with notice without alter" do
	  assert_respond_with_notice
	end
      end
      context "without to" do
        setup do
          make_param_with_exist_id
          post( :send_reply, @request_params,@session_params )
        end
	should "be redirected index with alert without notice" do
	  assert_respond_with_alert
	end
      end
    end
    context "with bad id" do 
      setup do
        make_param_with_bad_id
        post( :send_reply, @request_params,@session_params )
      end
      should "respond 404" do
        assert_response 404
      end
    end
  end

private
   def make_param
        @request_params = {:project_id => 1}
        @session_params = {:user_id => 1}
   end

   def make_param_with_exist_id
	make_param
        @request_params[:id] = 1
   end

   def make_param_with_bad_id
	make_param
        @request_params[:id] = 10
   end

   def add_param_to_to
        @request_params [:addr] = {:recipient1 => 'foo@example.com'}
        @request_params [:category] = {:recipient1 => 'to'}
	@request_params [:body] = 'this is a test.'
   end 

   def assert_respond_with_notice
     assert flash[:notice].present?,"notice is present"
     assert flash[:alert].blank?,"alert is blank"
     assert_redirected_to :action=> 'index'
   end

   def assert_respond_with_alert
     assert flash[:notice].blank?,"notice is blank"
     assert flash[:alert].present?,"alert is present"
     assert_redirected_to :action=> 'index'
   end

end
