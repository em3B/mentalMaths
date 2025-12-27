require "test_helper"

class ApplicationControllerTest < ActiveSupport::TestCase
  UserStub       = Struct.new(:role)
  InvitationStub = Struct.new(:accepted?, :expired?)

  class UnitController < ApplicationController
    def initialize
      super
      @__session = {}
    end

    def session
      @__session
    end
  end

  setup do
    @controller = UnitController.new
    @controller.request = ActionDispatch::TestRequest.create
  end

  # --- after_sign_in_path_for -------------------------------------------------

  test "after_sign_in_path_for routes teacher to teacher dashboard" do
    assert_equal "/dashboard/teacher", @controller.after_sign_in_path_for(UserStub.new("teacher"))
  end

  test "after_sign_in_path_for routes family to family dashboard" do
    assert_equal "/dashboard/family", @controller.after_sign_in_path_for(UserStub.new("family"))
  end

  test "after_sign_in_path_for routes student to topics path" do
    assert_equal "/topics", @controller.after_sign_in_path_for(UserStub.new("student"))
  end

  test "after_sign_in_path_for falls back to root for unknown role" do
    assert_equal "/", @controller.after_sign_in_path_for(UserStub.new("admin"))
  end

  test "after_sign_in_path_for falls back to root when role is nil" do
    assert_equal "/", @controller.after_sign_in_path_for(UserStub.new(nil))
  end

  # --- consume_school_invite_token -------------------------------------------

  test "consume_school_invite_token does nothing when pending token is missing" do
    @controller.send(:consume_school_invite_token)
    assert_nil @controller.session[:post_login_invite_token]
  end

  test "consume_school_invite_token ignores blank token and consumes it" do
    @controller.session[:pending_school_invite_token] = ""
    @controller.send(:consume_school_invite_token)

    assert_nil @controller.session[:pending_school_invite_token]
    assert_nil @controller.session[:post_login_invite_token]
  end

  test "consume_school_invite_token does not store when invitation not found" do
    token = "tok_missing"
    @controller.session[:pending_school_invite_token] = token

    with_school_invitation_find_by(token: token, returns: nil) do
      @controller.send(:consume_school_invite_token)
    end

    assert_nil @controller.session[:pending_school_invite_token]
    assert_nil @controller.session[:post_login_invite_token]
  end

  test "consume_school_invite_token stores post_login_invite_token when invitation valid" do
    token = "tok_123"
    @controller.session[:pending_school_invite_token] = token
    invitation = InvitationStub.new(false, false)

    with_school_invitation_find_by(token: token, returns: invitation) do
      @controller.send(:consume_school_invite_token)
    end

    assert_nil @controller.session[:pending_school_invite_token]
    assert_equal token, @controller.session[:post_login_invite_token]
  end

  test "consume_school_invite_token does not store when invitation accepted" do
    token = "tok_acc"
    @controller.session[:pending_school_invite_token] = token
    invitation = InvitationStub.new(true, false)

    with_school_invitation_find_by(token: token, returns: invitation) do
      @controller.send(:consume_school_invite_token)
    end

    assert_nil @controller.session[:pending_school_invite_token]
    assert_nil @controller.session[:post_login_invite_token]
  end

  test "consume_school_invite_token does not store when invitation expired" do
    token = "tok_exp"
    @controller.session[:pending_school_invite_token] = token
    invitation = InvitationStub.new(false, true)

    with_school_invitation_find_by(token: token, returns: invitation) do
      @controller.send(:consume_school_invite_token)
    end

    assert_nil @controller.session[:pending_school_invite_token]
    assert_nil @controller.session[:post_login_invite_token]
  end

  private

  def with_school_invitation_find_by(token:, returns:)
    original = SchoolInvitation.method(:find_by)

    SchoolInvitation.define_singleton_method(:find_by) do |args|
      raise "expected find_by(token: #{token.inspect}) got #{args.inspect}" unless args == { token: token }
      returns
    end

    yield
  ensure
    SchoolInvitation.define_singleton_method(:find_by) do |*args|
      original.call(*args)
    end
  end
end
