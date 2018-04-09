class CleanupUnknownOtherFtaOwnershipType < ActiveRecord::DataMigration
  def up
    unknown = FtaOwnershipType.find_by(name: 'Unknown')
    Asset.where(fta_ownership_type_id: unknown.id).update_all(fta_ownership_type_id: FtaOwnershipType.find_by(name: 'Other').id, other_fta_ownership_type: 'Unknown')

    unknown.destroy!
  end
end