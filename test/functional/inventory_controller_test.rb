require 'test_helper'

class InventoryControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get browse" do
    get :browse
    assert_response :success
  end

  test "should get _search_form" do
    get :_search_form
    assert_response :success
  end

  test "should get _browse_form" do
    get :_browse_form
    assert_response :success
  end

  test "should get _policy_short" do
    get :_policy_short
    assert_response :success
  end

  test "should get _policy_full" do
    get :_policy_full
    assert_response :success
  end

  test "should get item" do
    get :item
    assert_response :success
  end

  test "should get _search_results" do
    get :_search_results
    assert_response :success
  end

  test "should get _browse_results" do
    get :_browse_results
    assert_response :success
  end

end
