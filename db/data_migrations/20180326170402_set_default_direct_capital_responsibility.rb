class SetDefaultDirectCapitalResponsibility < ActiveRecord::DataMigration
  def up
    # update all nil (since we dont know if they're responsibile or not) default to completely responsible
    Asset.where(pcnt_capital_responsibility: nil).update_all(pcnt_capital_responsibility: 100)

    # update all 0 to nil because direct_capital_responsibility (as boolean) looks if pcnt_capital_responsibility is nil or not
    # ie 0 should never be an allowed value
    Asset.where(pcnt_capital_responsibility: 0).update_all(pcnt_capital_responsibility: nil)

  end
end