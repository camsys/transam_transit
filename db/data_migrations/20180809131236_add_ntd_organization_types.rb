class AddNtdOrganizationTypes < ActiveRecord::DataMigration
  def up
    ntd_organization_types = [
        {name: 'Area Agency on Aging', active: true},
        {name: 'City, County or Local Government Unit or Department of Transportation', active: true},
        {name: 'Independent Public Agency or Authority of Transit Service', active: true},
        {name: 'MPO, COG or Other Planning Agency', active: true},
        {name: 'Other Publicly-Owned or Privately Chartered Corporation', active: true},
        {name: 'Private-For-Profit Corportation', active: true},
        {name: 'Private-Non-Profit Corportation', active: true},
        {name: 'State Government Unit or Department of Transportation', active: true},
        {name: 'Tribe', active: true},
        {name: 'University', active: true},
        {name: 'Other', active: true},
    ]

    ntd_organization_types.each do |type|
      NtdOrganizationType.create!(type)
    end

  end
end