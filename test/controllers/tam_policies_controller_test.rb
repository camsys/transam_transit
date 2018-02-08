require 'test_helper'

class TamPoliciesControllerTest < ActionController::TestCase
  setup do
    @tam_policy = tam_policies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tam_policies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tam_policy" do
    assert_difference('TamPolicy.count') do
      post :create, tam_policy: {  }
    end

    assert_redirected_to tam_policy_path(assigns(:tam_policy))
  end

  test "should show tam_policy" do
    get :show, id: @tam_policy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tam_policy
    assert_response :success
  end

  test "should update tam_policy" do
    patch :update, id: @tam_policy, tam_policy: {  }
    assert_redirected_to tam_policy_path(assigns(:tam_policy))
  end

  test "should destroy tam_policy" do
    assert_difference('TamPolicy.count', -1) do
      delete :destroy, id: @tam_policy
    end

    assert_redirected_to tam_policies_path
  end
end
