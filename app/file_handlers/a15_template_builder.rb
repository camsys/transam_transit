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
        row_data << facility.facility_id #A
        row_data << facility.name #B
        row_data << (facility.part_of_larger_facility ? 'Yes' : 'No') #C
        row_data << facility.address #D
        row_data << facility.city #E
        row_data << facility.state #F
        row_data << facility.zip #G
        row_data << facility.latitude #H
        row_data << facility.longitude #I
        row_data << facility.reported_condition_rating #J
        row_data << facility.reported_condition_date #K
        row_data << facility.primary_mode #L
        row_data << facility.secondary_mode #M
        row_data << facility.private_mode #N
        row_data << facility.facility_type #O
        row_data << facility.year_built #P
        row_data << facility.size #Q
        row_data << '' #R (NOT REQUIRED)
        row_data << facility.pcnt_capital_responsibility #S
        row_data << facility.notes #T
        row_data << '' #U
      else
        row_data << ['']*21
      end
      row_data << ''
      sheet.add_row row_data.flatten.map{|x| x.to_s}
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
    facility_types = FtaFacilityType.active 
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

    # Private Mode
    sheet.add_data_validation("N2:N1000",
    {
        type: :list,
        formula1: "lists!$A$5:$#{@private_modes_end_column}$5"
    })

    # Facility Types
    sheet.add_data_validation("O2:O1000",
    {
        type: :list,
        formula1: "lists!$A$6:$#{@facility_types_end_column}$6"
    })

    # Year Built
    sheet.add_data_validation("P2:P1000",
    {
        type: :list,
        formula1: "lists!$A$7:$#{@years_end_column}$7"
    })

    # Delete
    sheet.add_data_validation("U3:U1000",
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
      'Secondary Modes', #M
      'Private Mode', #N
      'Facility Type', #O
      'Year Built or Reconstructed as New', #P
      'Square Feet', #Q
      'Parking Spaces', #R
      'Transit Agency Capital Responsiblity (%)', #S
      'Notes', #T
      'Delete' #U
    ]

    [detail_row]
  end

  def column_styles
    styles = [
      {:name => 'latlong', :column => 7, :options => {:row_offset => 1}},
      {:name => 'latlong', :column => 8, :options => {:row_offset => 1}}
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
    # number formatting for lat/long
    a << {name: 'latlong', format_code: "#.000000"}
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
