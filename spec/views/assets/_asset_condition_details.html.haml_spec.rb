require 'rails_helper'

describe "assets/_asset_condition_details.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :in_service_date => Date.new(Date.today.year-5,Date.today.month,Date.today.day), :reported_mileage => 1234, :reported_condition_type => ConditionType.first, :last_maintenance_date => Date.new(2013,1,1))
    render 'assets/asset_condition_details', :asset => Asset.get_typed_asset(test_asset)

    expect(rendered).to have_content('5 yrs')
    #expect(rendered).to have_content('1,234') skip check as check now is through mileage updates / asset events not saved in db column with TransamAsset
    expect(rendered).to have_content('01/01/2013')
  end
end
