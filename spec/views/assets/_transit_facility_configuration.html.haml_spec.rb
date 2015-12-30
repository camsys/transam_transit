require 'rails_helper'

describe "assets/_transit_facility_configuration.html.haml", :type => :view do

  it 'info' do
    test_asset = create(:bus_shelter, :description => 'test building', :facility_size => 40, :manufacture_year => 2010, :pcnt_operational => 33, :num_structures => 11, :num_floors => 22, :num_parking_spaces_public => 33, :num_parking_spaces_private => 44, :lot_size => 55, :num_elevators => 13, :num_escalators => 17, :line_number => 'abc1234', :leed_certification_type_id => 1)
    test_asset.facility_features << FacilityFeature.first
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(test_asset.description)
    expect(rendered).to have_content('2010')
    expect(rendered).to have_content('33%')
    expect(rendered).to have_content('11')
    expect(rendered).to have_content('22')
    expect(rendered).to have_content('33')
    expect(rendered).to have_content('44')
    expect(rendered).to have_content('55')
    expect(rendered).to have_content('13')
    expect(rendered).to have_content('17')
    expect(rendered).to have_content('abc1234')
    expect(rendered).to have_content(LeedCertificationType.first.to_s)
    expect(rendered).to have_content(FacilityFeature.first.to_s)
  end
end
