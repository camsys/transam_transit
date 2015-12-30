require 'rails_helper'

describe "assets/_equipment_fta.html.haml", :type => :view do
  it 'fta' do
    assign(:asset, create(:equipment_asset, :fta_funding_type_id => 1))
    render

    expect(rendered).to have_content(FtaFundingType.first)
  end
end
