class RunAssetFleetBuilderAllOrgs < ActiveRecord::DataMigration
  def up
    revenue_fleet_type = AssetFleetType.find_by(class_name: 'RevenueVehicle')
    sys_user = User.first

    TransitOperator.all.each do |organization|
      builder = AssetFleetBuilder.new(revenue_fleet_type, organization)
      builder.build({action: FleetBuilderProxy::RESET_ALL_ACTION})

      msg = "Revenue asset fleets built for #{organization.short_name}."
      # Add a row into the activity table
      ActivityLog.create({:organization_id => organization.id, :user_id => sys_user.id, :item_type => "AssetFleetBuilder", :activity => msg, :activity_time => Time.now})
    end
  end
end