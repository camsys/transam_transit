class AddRevenueTrackNoCapitalResponsibility < ActiveRecord::DataMigration
  def up
    FtaTrackType.create!(name: 'Revenue Track - No Capital Replacement Responsibility', active: true) unless FtaTrackType.find_by(name: 'Revenue Track - No Capital Replacement Responsibility')
  end

  def down
    FtaTrackType.update!(name: 'Revenue Track - No Capital Replacement Responsibility', active: false)
  end
end