class DeactivateUnknownsInSeed < ActiveRecord::DataMigration
  def up
    [
        'FtaModeType',
        'FtaServiceType',
        'FtaFundingType',
        'FtaOwnershipType',
    ].each do |klass|
      unknown = klass.constantize.find_by(name: 'Unknown')
      unknown.update!(active: false) if unknown.present?
    end
  end

  def down
    [
        'FtaModeType',
        'FtaServiceType',
        'FtaFundingType',
        'FtaOwnershipType',
    ].each do |klass|
      unknown = klass.constantize.find_by(name: 'Unknown')
      unknown.update!(active: true) if unknown.present?
    end
  end
end