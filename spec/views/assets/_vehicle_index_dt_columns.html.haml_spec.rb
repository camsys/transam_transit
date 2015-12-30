require 'rails_helper'

describe "assets/_vehicle_index_dt_columns.html.haml", :type => :view do
  it 'info' do
    render 'assets/vehicle_index_dt_columns', :a => create(:buslike_asset, :reported_mileage => 12345, :last_maintenance_date => Date.new(2010,1,1))

    expect(rendered).to have_content('12,345')
    expect(rendered).to have_content('01/01/2010')
  end
end
