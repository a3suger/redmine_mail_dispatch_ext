require File.expand_path('../../test_helper', __FILE__)
#
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

class MailUsersControllerTest < ActionController::TestCase

  context "#index" do
    should "respond success and render index template" do
      get :index
      assert_response :success
      assert_template 'index'
    end
  end

  context "#show" do
    setup do
      make_user
    end
    context "with exist user id" do
      should "respond success, render show template and include table tag" do
        get :show ,{:id => @user.id} 
        assert_response :success
        assert_template 'show'
      end
    end
    context "with bad user id" do
      should "respond 404" do
        get :show ,{:id => '10'} 
        assert_response 404
      end
    end
    teardown do
      destroy_user
    end
  end

  context "#new" do
    should "respond success and render new template" do
      get :new
      assert_response :success
      assert_template 'new'
    end
  end

  context "#create" do
    context "with valid data" do
      mail = 'testcreate@example.org'
      should "add user item and redirect index" do
        assert_difference 'MailUser.count' do
          post :create ,:mail_user => {:mail => mail}
        end
        assert MailUser.find_by_mail(mail).present?,'a mail user is created.'
        assert_redirected_to :action => 'index'
      end
    end
    context "with invalid data" do
      should "not add user item and render new template" do
        assert_no_difference 'MailUser.count' do
          post :create ,:mail_user => {:mail => ''}
        end
        assert_response :success
        assert_template 'new'
      end
    end
  end

  context "#update" do
    setup do
      make_user
    end
    context "with valid data" do
      should "update user item, and redirect show" do
        name = 'testcreate'
        post :update ,{:id => @user.id, :mail_user => {:name => name}}
        assert_redirected_to :action => 'show'
        assert_equal name, MailUser.find_by_id(@user.id).name
      end
    end
    context "with invalid data" do
      should "not update user item, and render edit" do
        post :update ,{:id => @user.id, :mail_user => {:mail => ''}}
        assert_response :success
        assert_template 'edit'
      end
    end
    teardown do
      destroy_user
    end
  end

private

  def make_user
    @mail = 'test@example.com'
    @user = MailUser.create(:mail => @mail)
  end
  def destroy_user
    @user.destroy
  end
end
