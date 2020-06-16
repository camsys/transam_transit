#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A15TemplateBuilder < TemplateBuilder

  attr_accessor :ntd_report

  @states_end_column = nil
  @modes_end_column = nil
  @private_modes_end_column = nil
  @facility_types_end_column = nil
  @years_end_column = nil

  SHEET_NAME = "A-15"

  def us_states
    [
    ['Alabama', 'AL'],
    ['Alaska', 'AK'],
    ['Arizona', 'AZ'],
    ['Arkansas', 'AR'],
    ['California', 'CA'],
    ['Colorado', 'CO'],
    ['Connecticut', 'CT'],
    ['Delaware', 'DE'],
    ['District of Columbia', 'DC'],
    ['Florida', 'FL'],
    ['Georgia', 'GA'],
    ['Hawaii', 'HI'],
    ['Idaho', 'ID'],
    ['Illinois', 'IL'],
    ['Indiana', 'IN'],
    ['Iowa', 'IA'],
    ['Kansas', 'KS'],
    ['Kentucky', 'KY'],
    ['Louisiana', 'LA'],
    ['Maine', 'ME'],
    ['Maryland', 'MD'],
    ['Massachusetts', 'MA'],
    ['Michigan', 'MI'],
    ['Minnesota', 'MN'],
    ['Mississippi', 'MS'],
    ['Missouri', 'MO'],
    ['Montana', 'MT'],
    ['Nebraska', 'NE'],
    ['Nevada', 'NV'],
    ['New Hampshire', 'NH'],
    ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'],
    ['New York', 'NY'],
    ['North Carolina', 'NC'],
    ['North Dakota', 'ND'],
    ['Ohio', 'OH'],
    ['Oklahoma', 'OK'],
    ['Oregon', 'OR'],
    ['Pennsylvania', 'PA'],
    ['Puerto Rico', 'PR'],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    ['Tennessee', 'TN'],
    ['Texas', 'TX'],
    ['Utah', 'UT'],
    ['Vermont', 'VT'],
    ['Virginia', 'VA'],
    ['Washington', 'WA'],
    ['West Virginia', 'WV'],
    ['Wisconsin', 'WI'],
    ['Wyoming', 'WY']
    ]
  end

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    facilities = @ntd_report.ntd_facilities

    row_count = facilities.count

    #(0..row_count - 1).each do |idx|
    facilities.each do |facility|
      row_data = []
      if facility
        row_data << {data: facility.facility_id} #A
        row_data << {data: facility.name}#B
        row_data << {data: (facility.part_of_larger_facility ? 'Yes' : 'No')} #C
        row_data << {data: facility.address} #D
        row_data << {data: facility.city} #E
        row_data << {data: facility.state} #F
        row_data << {data: facility.zip} #G
        row_data << {data: facility.latitude.nil? ? nil : "%.6f" % facility.latitude, type: :text} #H
        row_data << {data: facility.longitude.nil? ? nil : "%.6f" % facility.longitude, type: :text} #I
        row_data << {data: facility.reported_condition_rating, type: :text} #J
        row_data << {data: facility.reported_condition_date&.strftime("%m/%d/%Y"), type: :text} #K
        row_data << {data: facility.primary_mode} #L
        row_data << {data: ''} #M
        row_data << {data: facility.secondary_mode} #N
        row_data << {data: facility.private_mode} #O
        row_data << {data: facility.facility_type} #P
        row_data << {data: facility.year_built} #Q
        row_data << {data: facility.size} #R
        row_data << {data: facility.parking_measurement} #S
        row_data << {data: facility.pcnt_capital_responsibility} #T
        row_data << {data: facility.notes} #U
        row_data << {data: ''} #V
      else
        row_data << {data: ['']*22}
      end
      row_data << {data: ''}
      sheet.add_row row_data.map{|x| x[:data].to_s}, :types => row_data.map{|x| x[:type] || nil}
    end


  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
    
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    alphabet = ('A'..'ZZZ').to_a

    # Basic Booleans (Row 1)
    booleans= ["Yes", "No"]
    sheet.add_row make_row(booleans)

    # States (Row 2)
    states = us_states.map{|x| x.last}
    @states_end_column = alphabet[states.count]
    sheet.add_row make_row(states)
    
    # Condition Assessment (Row 3)
    assessment = ["NA", "1", "2", "3", "4", "5"]
    sheet.add_row make_row(assessment)

    # Modes (Row 4)
    modes = FtaModeType.active
    @modes_end_column = alphabet[modes.count]
    sheet.add_row make_row(modes)

    #Private Mode (Row 5)
    private_modes = FtaPrivateModeType.active 
    @private_modes_end_column = alphabet[private_modes.count]
    sheet.add_row make_row(private_modes)

    #Facility Types (Row 6)
    facility_types = FtaFacilityType.active.map{|facility_type| "#{facility_type} #{(facility_type.to_s.downcase.include?('combined') || facility_type.to_s.downcase.include?('other')) ? '(describe in Notes)' : ''}"}
    @facility_types_end_column = alphabet[facility_types.count]
    sheet.add_row make_row(facility_types)

    #Years (Row 7)
    years = (1800..Time.now.year).to_a.reverse
    @years_end_column = alphabet[years.count]
    sheet.add_row make_row(years)
  end

  def make_row objects
    row = []
    objects.each do |object|
      row << object.to_s 
    end
    return row
  end

  # Performing post-processing
  def post_process(sheet)

    # Section of Larger Facility
    sheet.add_data_validation("C2:C1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    # States
    sheet.add_data_validation("F2:F1000",
    {
        type: :list,
        formula1: "lists!$A$2:$#{@states_end_column}$2"
    })

    # Condition
    sheet.add_data_validation("J2:J1000",
    {
        type: :list,
        formula1: "lists!$A$3:$F$3"
    })

    # Primary Mode
    sheet.add_data_validation("L2:L1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@modes_end_column}$4"
    })

    # Non-Agency Mode
    sheet.add_data_validation("M2:M1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@modes_end_column}$4"
    })

    # Private Mode
    sheet.add_data_validation("O2:O1000",
    {
        type: :list,
        formula1: "lists!$A$5:$#{@private_modes_end_column}$5"
    })

    # Facility Types
    sheet.add_data_validation("P2:P1000",
    {
        type: :list,
        formula1: "lists!$A$6:$#{@facility_types_end_column}$6"
    })

    # Year Built
    sheet.add_data_validation("Q2:Q1000",
    {
        type: :list,
        formula1: "lists!$A$7:$#{@years_end_column}$7"
    })

    # Delete
    sheet.add_data_validation("V3:V1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })


  end

  # header rows
  def header_rows
    detail_row = [
      'Facilty ID', #A
      'Name', #B
      'Section of Larger Facility?', #C
      'Street', #D
      'City', #E
      'State', #F
      'Zip', #G
      'Lat', #H
      'Long', #I
      'Conditional Assessment', #J
      'Est. Date of Condition Assessment', #K
      'Primary Mode', #L
      'Non-Agency Mode', #M
      'Secondary Modes', #N
      'Private Mode', #O
      'Facility Type', #P
      'Year Built or Reconstructed as New', #Q
      'Square Feet', #R
      'Parking Spaces', #S
      'Transit Agency Capital Responsiblity (%)', #T
      'Notes', #U
      'Delete' #V
    ]

    [detail_row]
  end

  def column_styles
    styles = [
    ]
    styles
  end

  def row_styles
    styles = [
      {:name => 'lt-gray', :row => 0}
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
    a << {name: 'lt-gray', bg_color: "A9A9A9"}
    a << { name: 'gray', bg_color: "808080"}
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
