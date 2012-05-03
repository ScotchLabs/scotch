require 'test_helper'

class KnominationsControllerTest < ActionController::TestCase
  setup do
    @knomination = knominations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:knominations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create knomination" do
    assert_difference('Knomination.count') do
      post :create, :knomination => @knomination.attributes
    end

    assert_redirected_to knomination_path(assigns(:knomination))
  end

  test "should show knomination" do
    get :show, :id => @knomination.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @knomination.to_param
    assert_response :success
  end

  test "should update knomination" do
    put :update, :id => @knomination.to_param, :knomination => @knomination.attributes
    assert_redirected_to knomination_path(assigns(:knomination))
  end

  test "should destroy knomination" do
    assert_difference('Knomination.count', -1) do
      delete :destroy, :id => @knomination.to_param
    end

    assert_redirected_to knominations_path
  end
end
