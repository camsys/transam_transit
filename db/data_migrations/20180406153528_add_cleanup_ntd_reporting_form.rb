class AddCleanupNtdReportingForm < ActiveRecord::DataMigration
  def up
    form = Form.find_or_initialize_by(controller: 'ntd_forms')

    form.update!({
     :name=>"NTD Reporting",
     :description=>"NTD Annual Reporting Forms.",
     :roles=>"guest,guest,user,admin,manager,transit_manager",
     :active=>true
    })
  end
end