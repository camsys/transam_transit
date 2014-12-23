#------------------------------------------------------------------------------
#
# Vehicle Replacement Report
#
# Generates a report of vehicles that are scheduled to be replaced in a
# selected fiscal year
#
#------------------------------------------------------------------------------
class VehicleReplacementReport < AbstractReport

  # include the fiscal year mixin
  include FiscalYear

  def initialize(attributes = {})
    super(attributes)
  end

  # returns summary of count and cost for assets to be disposed by fiscal year, type, and subtype
  def get_data(organization_id_list, params)

    # Check to see if we got an asset sub type to filter by
    asset_subtype_id =  params[:asset_subtype_id] ? params[:asset_subtype_id].to_i : 0

    # Check to see if we got an asset sub type to filter by
    fiscal_year =  params[:fy_year] ? params[:fy_year].to_i : current_planning_year_year

    # labels
    labels = ['Fiscal Year', 'Type', 'Subtype', 'Count', 'Total Cost']

    # summary table of report
    service = AssetDispositionService.new

    # Figure out what asset subtypes are being selected
    vehicle_asset_type_ids = AssetType.where(:class_name => 'Vehicle').pluck(:id)
    if asset_subtype_id > 0
      asset_subtypes = AssetSubtype.where(:asset_subtype_id => asset_subtype_id)
    else
      asset_subtypes = AssetSubtype.where(:asset_type_id => vehicle_asset_type_ids).order(:asset_type_id, :id)
    end

    # Create a summary table for each asset and asset subtype
    data = []
    vehicle_asset_type_ids.each do |asset_type_id|
      asset_subtypes.each do |asset_subtype|

        assets = service.disposition_list(organization_id_list, fiscal_year, asset_type_id, asset_subtype.id)
        Rails.logger.debug "disposition service returned #{assets.count} assets"
        unless assets.empty?
          data << {
            :fy_year => fiscal_year,
            :asset_type => asset_subtype.asset_type,
            :asset_subtype => asset_subtype,
            :count => assets.count,
            :total_cost => assets.sum(:estimated_replacement_cost)
          }
        end
      end
    end

    return {:labels => labels, :fy_year => fiscal_year, :data => data}

  end
end
