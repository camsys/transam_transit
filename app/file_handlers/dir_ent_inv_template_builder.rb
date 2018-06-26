#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class DirEntInvTemplateBuilder < TemplateBuilder

  attr_accessor :ntd_form

  SHEET_NAME = "A-80 DirEntInv"

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    facilities = @ntd_form.ntd_admin_and_maintenance_facilities(Organization.where(id: @ntd_form.organization_id))
    support_vehicles = @ntd_form.ntd_service_vehicle_fleets(Organization.where(id: @ntd_form.organization_id))
    rev_vehicles = @ntd_form.ntd_revenue_vehicle_fleets(Organization.where(id: @ntd_form.organization_id))

    row_count = [facilities.count, support_vehicles.count, rev_vehicles.count].max

    (0..row_count - 1).each do |idx|

      line = idx+1
      row_data = [line.to_s]

      facility = facilities[idx]
      if facility
        row_data << facility.facility_id
        row_data << facility.name
        row_data << facility.part_of_larger_facility ? 'X' : ''
        row_data << facility.address
        row_data << facility.city
        row_data << facility.state
        row_data << facility.zip
        row_data << facility.reported_condition_rating
        row_data << facility.reported_condition_date
        row_data << facility.primary_mode
        row_data << facility.secondary_mode
        row_data << facility.private_mode
        row_data << facility.facility_type
        row_data << facility.year_built
        row_data << facility.size
        #row_data << facility.parking_measurement
        row_data << facility.pcnt_capital_responsibility
        row_data << facility.notes
      else
          row_data << ['']*17
      end
      row_data << ''

      support_vehicle = support_vehicles[idx]
      if support_vehicle
        row_data << support_vehicle.sv_id
        row_data << support_vehicle.agency_fleet_id
        row_data << support_vehicle.fleet_name
        row_data << support_vehicle.vehicle_type
        row_data << support_vehicle.primary_fta_mode_type
        row_data << support_vehicle.manufacture_year
        row_data << support_vehicle.estimated_cost
        row_data << support_vehicle.useful_life_benchmark
        row_data << support_vehicle.useful_life_remaining
        row_data << support_vehicle.size
        row_data << support_vehicle.pcnt_capital_responsibility
        row_data << support_vehicle.estimated_cost_year
        row_data << support_vehicle.secondary_fta_mode_types
        row_data << support_vehicle.notes
      else
        row_data << ['']*14
      end
      row_data << ''

      rev_vehicle = rev_vehicles[idx]
      if rev_vehicle
        row_data << rev_vehicle.rvi_id
        row_data << rev_vehicle.agency_fleet_id
        row_data << rev_vehicle.vehicle_type
        row_data << rev_vehicle.size
        row_data << rev_vehicle.num_active
        row_data << rev_vehicle.dedicated
        row_data << rev_vehicle.direct_capital_responsibility ? '' : 'Yes'
        row_data << rev_vehicle.manufacture_code
        row_data << rev_vehicle.other_manufacturer
        row_data << rev_vehicle.model_number
        row_data << rev_vehicle.manufacture_year
        row_data << rev_vehicle.rebuilt_year
        row_data << rev_vehicle.fuel_type
        row_data << rev_vehicle.dual_fuel_type
        row_data << rev_vehicle.vehicle_length
        row_data << rev_vehicle.seating_capacity
        row_data << rev_vehicle.standing_capacity
        row_data << rev_vehicle.ownership_type
        row_data << rev_vehicle.funding_type
        row_data << rev_vehicle.num_ada_accessible
        row_data << "#{rev_vehicle.additional_fta_mode} #{rev_vehicle.additional_fta_service_type}"
        row_data << rev_vehicle.num_emergency_contingency
        row_data << rev_vehicle.useful_life_benchmark
        row_data << rev_vehicle.useful_life_remaining
        row_data << rev_vehicle.total_active_miles_in_period
        row_data << rev_vehicle.avg_lifetime_active_miles
        row_data << rev_vehicle.status
        row_data << rev_vehicle.notes
      else
        row_data << ['']*28
      end
      row_data << ''


      sheet.add_row row_data.flatten.map{|x| x.to_s}
    end


  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells
    # sheet.merge_cells("B1:CX1")
    # sheet.merge_cells("B2:O2")
    # sheet.merge_cells("Q2:AG2")
    # sheet.merge_cells("AI2:BC2")
    # sheet.merge_cells("BE2:BK2")
    # sheet.merge_cells("BN2:BU2")
    # sheet.merge_cells("BW2:CX2")

    # title_style = sheet.styles.add_style({:name => 'title', :bg_color => "87aee7", :b => true})
    # title_detail_style = sheet.styles.add_style({:b => true})
    #
    # (0..101).each do |cell_idx|
    #   sheet.rows[0].cells[cell_idx].style = title_style
    #   unless [0, 15, 33, 55, 63, 73].include? cell_idx # columns in between tables
    #     sheet.rows[1].cells[cell_idx].style = title_style
    #   end
    # end
    #
    # sheet.row_style 2, title_detail_style

  end

  # header rows
  def header_rows
    title_row = [
      'Form',
      'Name: Direct Entry Inventory (A-80)'
    ] + ['']*60

    sub_title_row =
        ['', 'Facility Inventory'] +
        ['']*17 +
        ['Service Vehicle Inventory'] +
        ['']*14 +
        ['Revenue Vehicle Inventory'] +
        ['']*27

    detail_row = [
      '',
      'Facility ID',
      'Name',
      'Section of Larger Facility?',
      'Street',
      'City',
      'State',
      'Zip',
      'Condition Assessment',
      'Est. Date of Condition Assessment',
      'Primary Mode',
      'Secondary Mode',
      'Private Mode',
      'Facility Type',
      'Year Built or Reconstructed as New',
      'Square Feet',
      #'Parking Spaces',
      'Transit Agency Capital Responsibility (%)',
      'Notes',
      '',
      'SV ID',
      'Agency Fleet ID',
      'Fleet Name',
      'Vehicle Type',
      'Primary Mode',
      'Year Manufactured',
      'Estimated Cost',
      'Useful Life Benchmark (Years)',
      'Useful Life Remaining (Years)',
      'Total Vehicles',
      'Transit Agency Capital Responsibility (%)',
      'Year Dollars of Estimated Cost',
      'Secondary Mode(s)',
      'Notes',
      '',
      'RVI ID.',
      'Agency Fleet ID',
      'Vehicle Type',
      'Total Vehicles',
      'Active Vehicles',
      'Dedicated Fleet',
      'No Capital Replacement Responsibility',
      'Manufacturer',
      'Describe Other Manufacturer',
      'Model',
      'Year Manufactured',
      'Year Rebuilt',
      'Fuel Type',
      'Dual Fuel Type',
      'Vehicle Length',
      'Seating Capacity',
      'Standing Capacity',
      'Ownership Type',
      'Funding Type',
      'ADA Accessible Vehicles',
      'Supports Another Mode/TOS',
      'Emergency Contingency Vehicles',
      'Useful Life Benchmark',
      'Useful Life Remaining',
      'Miles This Year',
      'Avg Lifetime Miles per Active Vehicle',
      'Status',
      'Notes'
    ]

    [title_row, sub_title_row, detail_row]
  end

  def column_styles
    styles = [
      # {:name => 'asset_id_col', :column => 0},
      # {:name => 'asset_id_col', :column => 1},
      # {:name => 'asset_id_col', :column => 2},
      # {:name => 'asset_id_col', :column => 3},
      # {:name => 'asset_id_col', :column => 4},
      # {:name => 'asset_id_col', :column => 5},
      #
      # {:name => 'service_status_string_locked', :column => 6},
      # {:name => 'service_status_date_locked',   :column => 7},
      # {:name => 'service_status_string',        :column => 8},
      # {:name => 'service_status_date',          :column => 9},
      #
      # {:name => 'condition_float_locked', :column => 10},
      # {:name => 'condition_date_locked',  :column => 11},
      # {:name => 'condition_float',        :column => 12},
      # {:name => 'condition_date',         :column => 13}
    ]

    styles
  end

  def row_types
    []
    types
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    # Header Styles
    #
    a << {:name => 'string', :bg_color => "87aee7"}

    # a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left }}
    #
    # a << {:name => 'service_status_string_locked', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'service_status_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'service_status_string', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }
    # a << {:name => 'service_status_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }
    #
    # a << {:name => 'condition_float_locked', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'condition_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'condition_float', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }
    # a << {:name => 'condition_date', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }
    #
    # a << {:name => 'mileage_integer_locked', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'mileage_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => true }
    # a << {:name => 'mileage_integer', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => false }
    # a << {:name => 'mileage_date', :format_code => 'MM/DD/YYYY', :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => false }

    a.flatten
  end

  def worksheet_name
    SHEET_NAME
  end

  private

  def initialize(*args)
    super
  end

end
