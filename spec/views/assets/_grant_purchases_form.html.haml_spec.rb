require 'rails_helper'

# use equipment form to check partial grant_purchases form

describe "assets/_equipment_form.html.haml", :type => :view do
  it 'fields' do
    assign(:organization, create(:organization))
    assign(:asset, Equipment.new(:asset_type => AssetType.find_by(:class_name => 'Equipment')))
    render

    expect(rendered).to have_field('asset_grant_purchases_attributes_1_grant_id')
    expect(rendered).to have_field('asset_grant_purchases_attributes_1_pcnt_purchase_cost')
  end
end
