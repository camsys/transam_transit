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
  belongs_to              :fta_agency_type
  
  # must have a single service area type
  belongs_to              :fta_service_area_type
      
  # every transit agency services a set of geographies
  has_and_belongs_to_many :districts,         :join_table => 'organizations_districts', :foreign_key => 'organization_id'
    
  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates               :fta_agency_type_id,        :presence => :true
  validates               :fta_service_area_type_id,  :presence => :true
  validates               :subrecipient_number,       :presence => :true
  validates               :team_number,               :presence => :true
  
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  
  # List of allowable form param hash keys  
  FORM_PARAMS = [
    'fta_agency_type_id',
    'fta_service_area_type_id',
    'indian_tribe',
    'subrecipient_number',
    'team_number',
    'district_ids' => []
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
      
