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

  # must have a single service area type
  belongs_to                :fta_service_area_type

  # Every transit agency has one or more fta mode types
  has_and_belongs_to_many   :fta_mode_types, :foreign_key => 'organization_id'

  # every transit agency services a set of geographies
  has_and_belongs_to_many   :districts,      :foreign_key => 'organization_id', :join_table => 'organizations_districts'

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates               :fta_agency_type_id,        :presence => true
  validates               :fta_service_area_type_id,  :presence => true
  #validates              :subrecipient_number,       :presence => true
  validates_format_of     :ntd_id_number,             :allow_nil => true, :allow_blank => true, :with => /\A\d{4}\z/

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :fta_agency_type_id,
    :fta_service_area_type_id,
    :indian_tribe,
    :subrecipient_number,
    :ntd_id_number,
    :fta_mode_type_ids => [],
    :district_ids => []
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
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
