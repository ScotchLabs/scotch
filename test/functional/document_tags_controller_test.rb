require 'test_helper'

class DocumentTagsControllerTest < ActionController::TestCase
  setup do
    @document_tag = document_tags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:document_tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create document_tag" do
    assert_difference('DocumentTag.count') do
      post :create, :document_tag => @document_tag.attributes
    end

    assert_redirected_to document_tag_path(assigns(:document_tag))
  end

  test "should show document_tag" do
    get :show, :id => @document_tag.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @document_tag.to_param
    assert_response :success
  end

  test "should update document_tag" do
    put :update, :id => @document_tag.to_param, :document_tag => @document_tag.attributes
    assert_redirected_to document_tag_path(assigns(:document_tag))
  end

  test "should destroy document_tag" do
    assert_difference('DocumentTag.count', -1) do
      delete :destroy, :id => @document_tag.to_param
    end

    assert_redirected_to document_tags_path
  end
end
