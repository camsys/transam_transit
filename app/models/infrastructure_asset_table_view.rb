class InfrastructureAssetTableView < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :infrastructure
  belongs_to :policy


  def self.get_default_table_headers()
    ["Asset ID", "Organization", "Line (from)", "From", "Line (to)", "To", "Class", "Subtype", "Description",
     "Main Line / Division", "Branch / Subdivision", "Track", "Segment Type", "Location", "Last Life Cycle Action",
     "Life Cycle Action Date"]
  end

  def self.get_all_table_headers()
    ["Asset ID", "Organization", "Line (from)", "From", "Line (to)", "To", "Class", "Subtype", "Description",
     "Main Line / Division", "Branch / Subdivision", "Track", "Segment Type", "Location", "Last Life Cycle Action",
     "Life Cycle Action Date", "External ID", "Status", "Primary Mode", "Lat / Long", "TERM Condition", "TERM Rating",
     "Date of Condition Assessment", "Funding Program (largest %)", "Cost (Purcahse)", "Performance Restrictions",
     "Date of Performance Restriction", "Direct Capital Responsibility", "Capital Responsibility %", "Replacement Status", "NTD ID"]
  end

  def age(on_date=Date.today)
    age_in_years = if transam_asset_in_service_date.nil?
                     0
                   else
                     ((on_date.year * 12 + on_date.month) - (transam_asset_in_service_date.year * 12 + transam_asset_in_service_date.month))/12.0
                   end
    [(age_in_years).floor, 0].max
  end

  def policy_analyzer()
    policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(revenue_vehicle.very_specific, policy)
  end

  def expected_useful_life
    transam_asset_purchased_new ? policy_analyzer.get_min_service_life_months : policy_analyzer.get_min_used_purchase_service_life_months
  end

  def direct_capital_responsibility
    transit_asset_pcnt_capital_responsibility.present?
  end

  def useful_life_benchmark
    if direct_capital_responsibility && transit_asset_fta_type_default_useful_life_benchmark
      transit_asset_fta_type_default_useful_life_benchmark + (transit_asset_fta_type_useful_life_benchmark_unit == 'year' ? (most_recent_rebuild_event_extended_useful_life_months || 0)/12 : 0)
    end
  end

end