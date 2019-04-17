class AddRevenueTrackNoCapitalResponsibility < ActiveRecord::DataMigration
  def up
    FtaTrackType.create!(name: 'Revenue Track - No Capital Replacement Responsibility', active: true)
  end

  def down
    FtaTrackType.update!(name: 'Revenue Track - No Capital Replacement Responsibility', active: false)
  end
end