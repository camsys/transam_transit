class CreatePnpSystemFilter < ActiveRecord::DataMigration
  def up
    query_param = QueryParam.new(:active => 1, :name => 'PNP', :description => "Private (not for profit) organizations")
    query_param.class_name = "UserOrganizationFilter"
    query_param.query_string = Organization.active.where("fta_agency_type_id = #{FtaAgencyType.find_by(name: "Private (Not for profit)").id}").to_sql
    query_param.save!

    bpt_org = Organization.find_by(short_name: 'BPT')
    sys_user = User.find_by_first_name('system')

    filter = UserOrganizationFilter.new(name: query_param.name, description: query_param.description, active: true)
    filter.sort_order = 0
    filter.users = User.where(organization: bpt_org)
    filter.resource = bpt_org
    filter.creator = sys_user
    filter.query_string = query_param.query_string
    filter.save!
  end

  def down
    UserOrganizationFilter.find_by(name: "PNP").destroy
    QueryParam.where(name: "PNP").destroy_all
  end
end