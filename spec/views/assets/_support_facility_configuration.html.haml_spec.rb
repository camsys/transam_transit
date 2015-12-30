require 'rails_helper'

describe "assets/_support_facility_configuration.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:administration_building, :description => 'test building', :facility_size => 40, :manufacture_year => 2010, :pcnt_operational => 33, :num_structures => 11, :num_floors => 22, :num_parking_spaces_public => 33, :num_parking_spaces_private => 44, :lot_size => 55, :line_number => 'abc1234', :leed_certification_type_id => 1)
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
    expect(rendered).to have_content('abc1234')
    expect(rendered).to have_content(LeedCertificationType.first.to_s)
  end
end
