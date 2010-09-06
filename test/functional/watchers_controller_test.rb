require 'test_helper'

class WatchersControllerTest < ActionController::TestCase
  setup do
    @watcher = watchers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:watchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create watcher" do
    assert_difference('Watcher.count') do
      post :create, :watcher => @watcher.attributes
    end

    assert_redirected_to watcher_path(assigns(:watcher))
  end

  test "should show watcher" do
    get :show, :id => @watcher.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @watcher.to_param
    assert_response :success
  end

  test "should update watcher" do
    put :update, :id => @watcher.to_param, :watcher => @watcher.attributes
    assert_redirected_to watcher_path(assigns(:watcher))
  end

  test "should destroy watcher" do
    assert_difference('Watcher.count', -1) do
      delete :destroy, :id => @watcher.to_param
    end

    assert_redirected_to watchers_path
  end
end
