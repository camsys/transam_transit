#------------------------------------------------------------------------------
# TransamTransitAsset
#
# Extends the default asset model with transit-specific properties and methods
#
#------------------------------------------------------------------------------
module TransamTransitAsset

  extend ActiveSupport::Concern

  included do


    #---------------------------------------------------------------------------
    # Callbacks
    #---------------------------------------------------------------------------
    after_initialize    :set_defaults

    # Clean up any HABTM associations before the asset is destroyed
    before_destroy { districts.clear }

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------

    # each asset uses a funding type
    belongs_to  :fta_funding_type

    # each asset was purchased using one or more grants
    has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy, :inverse_of => :asset

    # each asset was purchased using one or more grants
    has_many    :grants,  :through => :grant_purchases

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => lambda{|a| a[:grant_id].blank?}, :allow_destroy => true

    # each transit asset has zero or more maintenance provider updates. .
    has_many    :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent",  :foreign_key => :asset_id

    # Each asset can be associated with 0 or more districts
    has_and_belongs_to_many   :districts,  :foreign_key => :asset_id

    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------
    # Make sure each asset has a funding type set
    validates   :fta_funding_type,  :presence => :true

  end

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  module ClassMethods
    def self.allowable_params
      [
        :fta_funding_type_id,
        :grant_purchases_attributes => [GrantPurchase.allowable_params]
      ]
    end

  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------
  def searchable_fields
    a = []
    a << super
    [].each do |field|
      a << field
    end
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    [].each do |field|
      a << field
    end
    a.flatten
  end

  def update_methods
    a = []
    a << super
    [:update_maintenance_provider].each do |method|
      a << method
    end
    a.flatten
  end

  # Forces an update of an assets maintenance provider. This performs an update on the record.
  def update_maintenance_provider

    Rails.logger.info "Updating the recorded maintenance provider for asset = #{object_key}"

    unless new_record?
      if maintenance_provider_updates.empty?
        self.maintenance_provider_type = nil
      else
        event = maintenance_provider_updates.last
        self.maintenance_provider_type = event.maintenance_provider_type
      end
      save
    end
  end

  #-----------------------------------------------------------------------------
  protected
  #-----------------------------------------------------------------------------

  def set_defaults

  end

end
