class InfrastructureAssetTableView < ActiveRecord::Base

  include TransamFormatHelper

  def readonly?
    true
  end

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
     "Date of Performance Restriction", "Direct Capital Responsibility", "Capital Responsibility %", "NTD ID", "Replacement Status",
     "Replacement Policy Year", "Replacement Scheduled Year", "Scheduled Replacement Cost"]
  end

  def self.format_methods_to_sort_order_columns(sort_name)
    case sort_name
    when 'manufacturer'
      return 'transam_asset_manufacturer_name'
    when 'model'
      return 'transam_asset_other_manufacturer_model'
    when 'age'
      return 'transam_asset_in_service_date'
    when 'status'
      return 'most_recent_service_status_event_service_status_type_name'
    when 'replacement_status'
      return 'most_recent_early_replacement_event_replacement_status_type_name'
    when 'policy_replacement_year_as_fiscal_year'
      return 'transam_asset_policy_replacement_year'
    when 'scheduled_replacement_year_as_fiscal_year'
      return 'transam_asset_scheduled_replacement_year'
    end

    return sort_name
  end

  def manufacturer
    if(self.transam_asset_manufacturer_name == "Other (Describe)")
      return self.transam_asset_other_manufacturer
    else
      return "#{self.transam_asset_manufacturer_code} - #{self.transam_asset_manufacturer_name}"
    end
  end

  def model
    if(self.transam_asset_manufacturer_model_name == "Other")
      return self.transam_asset_other_manufacturer_model
    else
      return self.transam_asset_manufacturer_model_name
    end
  end

  def status
    if(self.service_status_event_id.nil?)
      return 'No Service Status Event Recorded'
    else
      self.most_recent_service_status_event_service_status_type_name
    end
  end

  # returns the number of years since the asset was placed in service.
  def age(on_date=Date.today)
    age_in_years = if transam_asset_in_service_date.nil?
                     0
                   else
                     ((on_date.year * 12 + on_date.month) - (transam_asset_in_service_date.year * 12 + transam_asset_in_service_date.month))/12.0
                   end
    [(age_in_years).floor, 0].max
  end

  def policy_analyzer()
      policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(infrastructure.very_specific, policy)
  end

  def expected_useful_life
    transam_asset_purchased_new ? policy_analyzer.get_min_service_life_months : policy_analyzer.get_min_used_purchase_service_life_months
    # 0
  end

  def expected_useful_life_adjusted
    if(!expected_useful_life.nil? && !self.most_recent_rebuild_event_extended_useful_life_months.nil?)
      return self.most_recent_rebuild_event_extended_useful_life_months + expected_useful_life
    else
      expected_useful_life
    end
  end

  def direct_capital_responsibility
    if transit_asset_pcnt_capital_responsibility.present?
      'YES'
    else
      'NO'
    end
  end

  # def useful_life_benchmark
  #   if direct_capital_responsibility && transit_asset_fta_type_default_useful_life_benchmark
  #     transit_asset_fta_type_default_useful_life_benchmark + (transit_asset_fta_type_useful_life_benchmark_unit == 'year' ? (most_recent_rebuild_event_extended_useful_life_months || 0)/12 : 0)
  #   end
  # end
  #
  # def useful_life_benchmark_adjusted
  #   if(!useful_life_benchmark.nil? && !self.most_recent_rebuild_event_extended_useful_life_months.nil?)
  #     return self.most_recent_rebuild_event_extended_useful_life_months + useful_life_benchmark
  #   else
  #     return 'No TAM Policy'
  #   end
  # end

  def replacement_status
    if self.has_attribute?(:most_recent_early_replacement_event_replacement_status_type_name)
      if most_recent_early_replacement_event_replacement_status_type_name.nil?
        return 'By Policy'
      else
        return most_recent_early_replacement_event_replacement_status_type_name
      end
    end
  end

  def policy_replacement_year_as_fiscal_year
    format_as_fiscal_year(self.transam_asset_policy_replacement_year)
  end

  def scheduled_replacement_year_as_fiscal_year
    format_as_fiscal_year(self.transam_asset_scheduled_replacement_year)
  end

  def transit_asset_fta_type_description
    if self.transit_asset_fta_asset_class_name == 'Guideway'
      return self.transit_asset_fta_guideway_type_name
    elsif transit_asset_fta_asset_class_name == 'Track'
      return self.transit_asset_fta_track_type_name
    elsif transit_asset_fta_asset_class_name == 'Power & Signal'
      return self.transit_asset_fta_power_and_signal_type_name
    end
  end

  def as_json(options={})
    super(options).merge!({
                              age: self.age,
                              direct_capital_responsibility: self.direct_capital_responsibility,
                              manufacturer: self.manufacturer,
                              model: self.model,
                              policy_replacement_year_as_fiscal_year: self.policy_replacement_year_as_fiscal_year,
                              replacement_status: self.replacement_status,
                              scheduled_replacement_year_as_fiscal_year: self.scheduled_replacement_year_as_fiscal_year,
                              scheduled_replacement_year: self.transam_asset_scheduled_replacement_year,
                              status: self.status,
                          })
  end

end