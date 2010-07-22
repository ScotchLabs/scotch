require 'test_helper'

class HelpItemsControllerTest < ActionController::TestCase
  setup do
    @help_item = help_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:help_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create help_item" do
    assert_difference('HelpItem.count') do
      post :create, :help_item => @help_item.attributes
    end

    assert_redirected_to help_item_path(assigns(:help_item))
  end

  test "should show help_item" do
    get :show, :id => @help_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @help_item.to_param
    assert_response :success
  end

  test "should update help_item" do
    put :update, :id => @help_item.to_param, :help_item => @help_item.attributes
    assert_redirected_to help_item_path(assigns(:help_item))
  end

  test "should destroy help_item" do
    assert_difference('HelpItem.count', -1) do
      delete :destroy, :id => @help_item.to_param
    end

    assert_redirected_to help_items_path
  end
end
