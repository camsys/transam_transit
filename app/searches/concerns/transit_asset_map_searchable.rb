# Asset map searcher in transit engine
#
module TransitAssetMapSearchable

  extend ActiveSupport::Concern

  included do

    attr_accessor :fta_asset_category_id,
                  :fta_asset_class_id,
                  :global_fta_type,
                  :fuel_type_id,
                  :min_mileage,
                  :max_mileage

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  module ClassMethods

  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  private

  def transit_klass
    if asset_type_class_name == 'TransamAsset'
      @transit_klass ||= TransitAsset.joins(:transam_asset)
    else
      @transit_klass = @klass
    end
  end

  def fta_asset_category_conditions
    clean_fta_asset_category_id = remove_blanks(fta_asset_category_id)

    transit_klass.where(fta_asset_category_id: clean_fta_asset_category_id) unless clean_fta_asset_category_id.empty?
  end

  def fta_asset_class_conditions
    clean_fta_asset_class_id = remove_blanks(fta_asset_class_id)
    transit_klass.where(fta_asset_class_id: clean_fta_asset_class_id) unless clean_fta_asset_class_id.empty?
  end

  def global_fta_type_conditions
    clean_fta_type = remove_blanks(global_fta_type).map{|g| GlobalID::Locator.locate g}
    transit_klass.where(fta_type: clean_fta_type) unless clean_fta_type.empty?
  end


  def fuel_type_conditions
    clean_fuel_type_id = remove_blanks(fuel_type_id)
    transit_klass.where(fuel_type_id: clean_fuel_type_id) unless clean_fuel_type_id.blank?
  end

  def min_mileage_conditions
    transit_klass.joins('LEFT JOIN recent_asset_events_views AS recent_milage ON recent_milage.base_transam_asset_id = transam_assets.id AND recent_milage.asset_event_name = "Mileage"').joins('LEFT JOIN asset_events AS mileage_event ON mileage_event.id = recent_milage.asset_event_id').where("mileage_event.current_mileage <= ?", min_mileage) unless min_mileage.blank?
  end
  def max_mileage_conditions
    transit_klass.joins('LEFT JOIN recent_asset_events_views AS recent_milage ON recent_milage.base_transam_asset_id = transam_assets.id AND recent_milage.asset_event_name = "Mileage"').joins('LEFT JOIN asset_events AS mileage_event ON mileage_event.id = recent_milage.asset_event_id').where("mileage_event.current_mileage >= ?", max_mileage) unless max_mileage.blank?
  end

end
