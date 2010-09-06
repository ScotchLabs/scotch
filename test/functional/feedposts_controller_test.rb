require 'test_helper'

class FeedpostsControllerTest < ActionController::TestCase
  setup do
    @feedpost = feedposts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedposts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedpost" do
    assert_difference('Feedpost.count') do
      post :create, :feedpost => @feedpost.attributes
    end

    assert_redirected_to feedpost_path(assigns(:feedpost))
  end

  test "should show feedpost" do
    get :show, :id => @feedpost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @feedpost.to_param
    assert_response :success
  end

  test "should update feedpost" do
    put :update, :id => @feedpost.to_param, :feedpost => @feedpost.attributes
    assert_redirected_to feedpost_path(assigns(:feedpost))
  end

  test "should destroy feedpost" do
    assert_difference('Feedpost.count', -1) do
      delete :destroy, :id => @feedpost.to_param
    end

    assert_redirected_to feedposts_path
  end
end
