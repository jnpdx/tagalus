require 'test_helper'

class DefinitionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:definitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create definition" do
    assert_difference('Definition.count') do
      post :create, :definition => { }
    end

    assert_redirected_to definition_path(assigns(:definition))
  end

  test "should show definition" do
    get :show, :id => definitions(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => definitions(:one).id
    assert_response :success
  end

  test "should update definition" do
    put :update, :id => definitions(:one).id, :definition => { }
    assert_redirected_to definition_path(assigns(:definition))
  end

  test "should destroy definition" do
    assert_difference('Definition.count', -1) do
      delete :destroy, :id => definitions(:one).id
    end

    assert_redirected_to definitions_path
  end
end
