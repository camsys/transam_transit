class UpdateFundingTypeSeedData < ActiveRecord::DataMigration
  def up
    # Update FtaFundingType
    fta_funding_types = [
      {:active => 1, :name => 'Urbanized Area Formula Program', :code => 'UA',    :description => 'UA-Urbanized Area Formula Program.'},
      {:active => 1, :name => 'Other Federal Funds',            :code => 'OF',    :description => 'OF-Other Federal Funds.'},
      {:active => 1, :name => 'Non-Federal Public Funds',       :code => 'NFPA',  :description => 'NFPA-Non-Federal Public Funds.'},
      {:active => 1, :name => 'Non-Federal Private Funds',      :code => 'NFPE',  :description => 'NFPE-Non-Federal Private Funds.'},
      {:active => 1, :name => 'Rural Area Formula Program',     :code => 'RAFP',  :description => 'RAFP-Rural Area Formula Program.'},
      {:active => 1, :name => 'Enhanced Mobility of Seniors & Individuals with Disabilities',      :code => 'EMSID',  :description => 'EMSID-Enhanced Mobility of Seniors & Individuals with Disabilities.'}
    ]
    fta_funding_types.each do |type|
      t = FtaFundingType.find_by(code: type[:code])
      t.update!(type)
    end
  end
end
