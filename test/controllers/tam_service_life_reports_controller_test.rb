require 'test_helper'

class TamServiceLifeReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tam_service_life_report = tam_service_life_reports(:one)
  end

  test "should get index" do
    get tam_service_life_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_tam_service_life_report_url
    assert_response :success
  end

  test "should create tam_service_life_report" do
    assert_difference('TamServiceLifeReport.count') do
      post tam_service_life_reports_url, params: { tam_service_life_report: {  } }
    end

    assert_redirected_to tam_service_life_report_url(TamServiceLifeReport.last)
  end

  test "should show tam_service_life_report" do
    get tam_service_life_report_url(@tam_service_life_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_tam_service_life_report_url(@tam_service_life_report)
    assert_response :success
  end

  test "should update tam_service_life_report" do
    patch tam_service_life_report_url(@tam_service_life_report), params: { tam_service_life_report: {  } }
    assert_redirected_to tam_service_life_report_url(@tam_service_life_report)
  end

  test "should destroy tam_service_life_report" do
    assert_difference('TamServiceLifeReport.count', -1) do
      delete tam_service_life_report_url(@tam_service_life_report)
    end

    assert_redirected_to tam_service_life_reports_url
  end
end
