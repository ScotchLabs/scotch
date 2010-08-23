require 'test_helper'

class FeedPostsControllerTest < ActionController::TestCase
  setup do
    @feed_post = feed_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feed_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feed_post" do
    assert_difference('FeedPost.count') do
      post :create, :feed_post => @feed_post.attributes
    end

    assert_redirected_to feed_post_path(assigns(:feed_post))
  end

  test "should show feed_post" do
    get :show, :id => @feed_post.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @feed_post.to_param
    assert_response :success
  end

  test "should update feed_post" do
    put :update, :id => @feed_post.to_param, :feed_post => @feed_post.attributes
    assert_redirected_to feed_post_path(assigns(:feed_post))
  end

  test "should destroy feed_post" do
    assert_difference('FeedPost.count', -1) do
      delete :destroy, :id => @feed_post.to_param
    end

    assert_redirected_to feed_posts_path
  end
end
