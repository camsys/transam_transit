#------------------------------------------------------------------------------
#
# Fta Agency
#
# Represents a TransitAgency that reports to FTA and must track
# NTD reporting characteristics
#
#------------------------------------------------------------------------------
class FtaAgency < TransitAgency

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # must have a single FTA agency type
  belongs_to                :fta_agency_type

  belongs_to                :ntd_organization_type

  # must have a single service area type
  belongs_to                :fta_service_area_type

  # Every transit agency has one or more fta mode types
  has_and_belongs_to_many   :fta_mode_types, :foreign_key => 'organization_id'

  # Every transit agency has one or more service provider types
  has_and_belongs_to_many  :service_provider_types, :foreign_key => 'organization_id'

  # every transit agency services a set of geographies
  has_and_belongs_to_many   :districts,      :foreign_key => 'organization_id', :join_table => 'organizations_districts'

  # DistrictType.active.each do |district_type|
  #   has_and_belongs_to_many (district_type.name.parameterize(separator: '_')+'_districts').to_sym, -> { where(district_type: district_type) },
  #                           :foreign_key => 'organization_id', :join_table => 'organizations_districts', :class_name => 'District'
  # end

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates               :fta_agency_type_id,        :presence => true
  validates               :fta_service_area_type_id,  :presence => true
  #validates              :subrecipient_number,       :presence => true
  
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :fta_agency_type_id,
    :ntd_organization_type_id,
    :fta_service_area_type_id,
    :service_area_population,
    :service_area_size,
    :service_area_size_unit,
    :indian_tribe,
    :subrecipient_number,
    :ntd_id_number,
    :fta_mode_type_ids,
    :service_provider_type_ids,
    :district_ids
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS + [DistrictType.active.pluck(:name).each_with_object({}) { |d,h|  h.update((d.parameterize(separator: '_')+'_district_ids').to_sym=>[]) }]
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Returns the user with the assigned role :director_transit_operations
  def director_transit_operations
    usrs = users_with_role :director_transit_operations
    if usrs.empty?
      nil
    else
      usrs.first
    end
  end

  # Returns the user with the assigned role :ntd_contact
  def ntd_contact
    usrs = users_with_role :ntd_contact
    if usrs.empty?
      nil
    else
      usrs.first
    end
  end

  def transit_managers
    users_with_role :transit_manager
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    super
    self.indian_tribe ||= false
  end

end
