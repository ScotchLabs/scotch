require 'test_helper'

class KudosControllerTest < ActionController::TestCase
  setup do
    @kudo = kudos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kudos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kudo" do
    assert_difference('Kudos.count') do
      post :create, :kudo => @kudo.attributes
    end

    assert_redirected_to kudo_path(assigns(:kudo))
  end

  test "should show kudo" do
    get :show, :id => @kudo.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @kudo.to_param
    assert_response :success
  end

  test "should update kudo" do
    put :update, :id => @kudo.to_param, :kudo => @kudo.attributes
    assert_redirected_to kudo_path(assigns(:kudo))
  end

  test "should destroy kudo" do
    assert_difference('Kudos.count', -1) do
      delete :destroy, :id => @kudo.to_param
    end

    assert_redirected_to kudos_index_path
  end
end
