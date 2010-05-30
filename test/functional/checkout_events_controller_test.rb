require 'test_helper'

class CheckoutEventsControllerTest < ActionController::TestCase
  setup do
    @checkout_event = checkout_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checkout_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create checkout_event" do
    assert_difference('CheckoutEvent.count') do
      post :create, :checkout_event => @checkout_event.attributes
    end

    assert_redirected_to checkout_event_path(assigns(:checkout_event))
  end

  test "should show checkout_event" do
    get :show, :id => @checkout_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @checkout_event.to_param
    assert_response :success
  end

  test "should update checkout_event" do
    put :update, :id => @checkout_event.to_param, :checkout_event => @checkout_event.attributes
    assert_redirected_to checkout_event_path(assigns(:checkout_event))
  end

  test "should destroy checkout_event" do
    assert_difference('CheckoutEvent.count', -1) do
      delete :destroy, :id => @checkout_event.to_param
    end

    assert_redirected_to checkout_events_path
  end
end
