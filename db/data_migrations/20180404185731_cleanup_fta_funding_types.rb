class CleanupFtaFundingTypes < ActiveRecord::DataMigration
  def up
    fta_funding_types = [
        {:active => 1, :name => 'Urbanized Area Formula Program', :code => 'UA',    :description => 'UA -Urbanized Area Formula Program.'},
        {:active => 1, :name => 'Other Federal funds',            :code => 'OF',    :description => 'OF-Other Federal funds.'},
        {:active => 1, :name => 'Non-Federal public funds',       :code => 'NFPA',  :description => 'NFPA-Non-Federal public funds.'},
        {:active => 1, :name => 'Non-Federal private funds',      :code => 'NFPE',  :description => 'NFPE-Non-Federal private funds.'},
        {:active => 1, :name => 'Rural Area Formula Program',     :code => 'RAFP',  :description => 'Rural Area Formula Program.'},
        {:active => 1, :name => 'Enhanced Mobility for Seniors and Individuals with Disabilities',      :code => 'EMSID',  :description => 'Enhanced Mobility for Seniors and Individuals with Disabilities.'},
        {:active => 0, :name => 'Unknown',                        :code => 'XX',    :description => 'FTA funding type not specified.'}
    ].each do |funding_type|
      FtaFundingType.create!(funding_type) if FtaFundingType.find_by(code: funding_type[:code]).nil?
    end
  end
end