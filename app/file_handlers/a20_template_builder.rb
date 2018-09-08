#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A20TemplateBuilder < TemplateBuilder

  attr_accessor :ntd_report

  @modes_end_column = nil
  @service_types_end_column = nil
  @fta_types_end_column = nil
  @allocation_units_end_column = nil

  SHEET_NAME = "A-20"


  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    infrastructures = @ntd_report.ntd_infrastructures

    row_count = infrastructures.count

    #(0..row_count - 1).each do |idx|
    infrastructures.each do |infrastructure|
      row_data = []
      if infrastructure
        row_data << infrastructure.fta_mode #A
        row_data << infrastructure.fta_service_type #B
        row_data << infrastructure.fta_type #C
        row_data << '' #D
        row_data << infrastructure.size #E
        row_data << infrastructure.linear_miles #F
        row_data << infrastructure.track_miles #G
        row_data << infrastructure.expected_service_life #H
        row_data << infrastructure.pcnt_capital_responsibility #I
        row_data << infrastructure.shared_capital_responsibility_organization #J
        row_data << infrastructure.description #K
        row_data << infrastructure.notes #L
        row_data << infrastructure.allocation_unit #M
        row_data << infrastructure.pre_nineteen_thirty #N
        row_data << infrastructure.nineteen_thirty #O
        row_data << infrastructure.nineteen_forty #P
        row_data << infrastructure.nineteen_fifty #Q
        row_data << infrastructure.nineteen_sixty #R
        row_data << infrastructure.nineteen_seventy #S
        row_data << infrastructure.nineteen_eighty #T
        row_data << infrastructure.nineteen_ninety #U
        row_data << infrastructure.two_thousand #V
        row_data << infrastructure.two_thousand_ten #W
      else
        row_data << ['']*23
      end
      sheet.add_row row_data.flatten.map{|x| x.to_s}
    end


  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
    
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    alphabet = ('A'..'ZZZ').to_a

    # Modes (Row 1)
    modes = FtaModeType.active
    @modes_end_column = alphabet[modes.count]
    sheet.add_row make_row(modes)

    # Service Types (Row 2)
    service_types = FtaServiceType.active
    @service_types_end_column = alphabet[service_types.count]
    sheet.add_row make_row(service_types)

    # Fta types (track, guideway, power&signal) (Row 3)
    fta_types = FtaTrackType.active + FtaGuidewayType.active + FtaPowerSignalType.active
    @fta_types_end_column = alphabet[fta_types.count]
    sheet.add_row make_row(fta_types)

    # Allocation Unit(Row 4)
    allocation_units = ['LM', 'TM', '%', 'Quantity']
    @allocation_units_end_column = alphabet[allocation_units.count]
    sheet.add_row make_row(allocation_units)
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

    # Modes
    sheet.add_data_validation("A2:A1000",
    {
        type: :list,
        formula1: "lists!$A$1:$#{@modes_end_column}$1"
    })

    # Service Types
    sheet.add_data_validation("B2:B1000",
    {
        type: :list,
        formula1: "lists!$A$2:$#{@service_types_end_column}$2"
    })

    # FTA types
    sheet.add_data_validation("C2:C1000",
    {
        type: :list,
        formula1: "lists!$A$3:$#{@fta_types_end_column}$3"
    })

    # Allocation unit
    sheet.add_data_validation("M2:M1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@allocation_units_end_column}$4"
    })


  end

  # header rows
  def header_rows
    detail_row = [
      'Mode', #A
      'Service', #B
      'Guideway Elements', #C
      'N/A', #D
      'Count', #E
      'Linear Miles', #F
      'Track Miles', #G
      'Expected Service Years When New', #H
      'Percent Agency Capital Responsibility (%)', #I
      'Agency with Shared Responsibility', #J
      'Other Description', #K
      'Notes', #L
      'Allocation Unit', #M
      'Pre-1930', #N
      '1930-1939', #O
      '1940-1949', #P
      '1950-1959', #Q
      '1960-1969', #R
      '1970-1979', #S
      '1980-1989', #T
      '1990-1999', #U
      '2000-2009', #V
      '2010- 2019', #W
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
