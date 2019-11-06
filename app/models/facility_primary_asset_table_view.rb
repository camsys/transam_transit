class FacilityPrimaryAssetTableView  < ActiveRecord::Base

  include TransamFormatHelper

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :facility
  belongs_to :transit_component
  belongs_to :policy

  def self.get_default_table_headers
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def self.get_all_table_headers
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date",
     "External ID", "Subtype", "Cost (Purchase)", "In Service Date", "Direct Capital Responsibility", "Description",
     "Service Life - Current", "TERM Condition", "TERM Rating", "Date of Condition Assessment",
     "Replace / Rehab Policy (ESL)", "ESL - Adjusted", "Date of Rebuild / Rehab",
     "Location", "Current Book Value", "Replacement Status", "Replacement Policy Year",
     "Replacement Scheduled Year", "Scheduled Replacement Cost"]
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

  def component_or_sub_component

    if !self.facility_component_type_name.nil?
      return 'Component'
    elsif !self.facility_component_subtype_name.nil?
      return 'Sub-Component'
    end
    return 'Primary Facility'
  end

  def component_or_sub_component_type
    if !self.facility_component_type_name.nil?
      return self.facility_component_type_name
    elsif !self.facility_component_subtype_name.nil?
      return self.facility_component_subtype_name
    end
    return nil
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
    if transit_component.nil?
      policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(facility.very_specific, policy)
    else
      policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(transit_component.very_specific, policy)
    end

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

  def as_json(options={})
    super(options).merge!({
                              age: self.age,
                              component_or_sub_component: self.component_or_sub_component,
                              component_or_sub_component_type: self.component_or_sub_component_type,
                              direct_capital_responsibility: self.direct_capital_responsibility,
                              expected_useful_life: self.expected_useful_life,
                              expected_useful_life_adjusted: self.expected_useful_life_adjusted,
                              manufacturer: self.manufacturer,
                              model: self.model,
                              policy_replacement_year_as_fiscal_year: self.policy_replacement_year_as_fiscal_year,
                              replacement_status: self.replacement_status,
                              scheduled_replacement_year_as_fiscal_year: self.scheduled_replacement_year_as_fiscal_year,
                              scheduled_replacement_year: self.transam_asset_scheduled_replacement_year,
                              status: self.status
                          })
  end

end