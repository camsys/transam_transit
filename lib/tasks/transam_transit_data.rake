# desc "Explaining what the task does"
# task :transam_transit do
#   # Task goes here
# end
namespace :transam_transit_data do

  task add_early_disposition_requests_bulk_update: :environment do
    unless FileContentType.find_by(builder_name: "TransitEarlyDispositionRequestUpdatesTemplateBuilder").present?
      FileContentType.create!({:active => 1, :name => 'Early Disposition Requests', :class_name => 'EarlyDispositionRequestUpdatesFileHandler', :builder_name => "TransitEarlyDispositionRequestUpdatesTemplateBuilder", :description => 'Worksheet requests early disposition for existing inventory.'})
    end
  end

  desc 'add roles list for org types'
  task add_roles_organization_types: :environment do
    OrganizationType.find_by(class_name: 'Grantor').update!(roles: 'guest,manager')
    OrganizationType.find_by(class_name: 'TransitOperator').update!(roles: 'guest,user,transit_manager')
    OrganizationType.find_by(class_name: 'PlanningPartner').update!(roles: 'guest')
  end

end