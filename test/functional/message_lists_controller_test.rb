require 'test_helper'

class MessageListsControllerTest < ActionController::TestCase
  setup do
    @message_list = message_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:message_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create message_list" do
    assert_difference('MessageList.count') do
      post :create, message_list: @message_list.attributes
    end

    assert_redirected_to message_list_path(assigns(:message_list))
  end

  test "should show message_list" do
    get :show, id: @message_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @message_list
    assert_response :success
  end

  test "should update message_list" do
    put :update, id: @message_list, message_list: @message_list.attributes
    assert_redirected_to message_list_path(assigns(:message_list))
  end

  test "should destroy message_list" do
    assert_difference('MessageList.count', -1) do
      delete :destroy, id: @message_list
    end

    assert_redirected_to message_lists_path
  end
end
