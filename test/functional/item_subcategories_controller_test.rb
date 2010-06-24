require 'test_helper'

class ItemSubcategoriesControllerTest < ActionController::TestCase
  setup do
    @item_subcategory = item_subcategories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_subcategories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item_subcategory" do
    assert_difference('ItemSubcategory.count') do
      post :create, :item_subcategory => @item_subcategory.attributes
    end

    assert_redirected_to item_subcategory_path(assigns(:item_subcategory))
  end

  test "should show item_subcategory" do
    get :show, :id => @item_subcategory.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @item_subcategory.to_param
    assert_response :success
  end

  test "should update item_subcategory" do
    put :update, :id => @item_subcategory.to_param, :item_subcategory => @item_subcategory.attributes
    assert_redirected_to item_subcategory_path(assigns(:item_subcategory))
  end

  test "should destroy item_subcategory" do
    assert_difference('ItemSubcategory.count', -1) do
      delete :destroy, :id => @item_subcategory.to_param
    end

    assert_redirected_to item_subcategories_path
  end
end
