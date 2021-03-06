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

  def build

    if @ntd_report.ntd_infrastructures.count > 0

      # Create a new workbook
      p = Axlsx::Package.new
      wb = p.workbook

      # Call back to setup any implementation specific options needed
      setup_workbook(wb)

      @ntd_report.ntd_infrastructures.distinct.pluck(:fta_mode, :fta_service_type).each do |mode_tos|
        worksheet_name = "#{mode_tos[0].split('-')[0].strip} #{mode_tos[1].split('-')[0].strip}"

        # Add the worksheet
        sheet = wb.add_worksheet(:name => worksheet_name)

        # setup any styles and cache them for later
        style_cache = {}
        styles.each do |s|
          Rails.logger.debug s.inspect
          style = wb.styles.add_style(s)
          Rails.logger.debug style.inspect
          style_cache[s[:name]] = style
        end
        Rails.logger.debug style_cache.inspect
        # Add the header rows
        title = sheet.styles.add_style(:bg_color => "00A9A9A9", :sz=>12)
        header_rows.each do |header_row|
          sheet.add_row header_row, :style => title
        end

        # add the rows
        add_rows(sheet, mode_tos)

        # Add the column styles
        column_styles.each do |col_style|
          Rails.logger.debug col_style.inspect
          sheet.col_style col_style[:column], style_cache[col_style[:name]]
        end

        # Add the row styles
        row_styles.each do |row_style|
          Rails.logger.debug row_style.inspect
          sheet.row_style row_style[:row], style_cache[row_style[:name]]
        end

        # set column widths
        sheet.column_widths *column_widths

        # Perform any additional processing
        post_process(sheet)
      end

      # Serialize the spreadsheet to the stream and return it
      p.to_stream()
    end

  end


  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet, mode_tos)

    infrastructures = @ntd_report.ntd_infrastructures.where(fta_mode: mode_tos[0], fta_service_type: mode_tos[1])

    (FtaTrackType.pluck(:name, :sort_order) + FtaGuidewayType.pluck(:name,:sort_order) + FtaPowerSignalType.pluck(:name, :sort_order)).sort_by{|x| x[1]}.map{|y| "#{y[1]}. #{y[0]}"}.each do |guideway_element|
      row_data = []
      guideway_element_str = guideway_element.split('.').last.strip
      infrastructure = infrastructures.find_by(fta_type: guideway_element_str)
      if infrastructure
        row_data << infrastructure.fta_mode #A
        row_data << infrastructure.fta_service_type #B
        row_data << guideway_element #C
        row_data << '' #D
        row_data << infrastructure.size #E
        row_data << infrastructure.track_miles #F
        row_data << infrastructure.expected_service_life #G
        row_data << infrastructure.pcnt_capital_responsibility #H
        row_data << infrastructure.shared_capital_responsibility_organization #I
        row_data << infrastructure.description #J
        row_data << infrastructure.notes #K
        row_data << infrastructure.allocation_unit #L
        row_data << infrastructure.pre_nineteen_thirty #M
        row_data << infrastructure.nineteen_thirty #N
        row_data << infrastructure.nineteen_forty #O
        row_data << infrastructure.nineteen_fifty #P
        row_data << infrastructure.nineteen_sixty #Q
        row_data << infrastructure.nineteen_seventy #R
        row_data << infrastructure.nineteen_eighty #S
        row_data << infrastructure.nineteen_ninety #T
        row_data << infrastructure.two_thousand #U
        row_data << infrastructure.two_thousand_ten #V
        row_data << infrastructure.two_thousand_twenty #W
        row_data << '' #X Placeholder for Tracks Miles Under Performance Restriction
      else
        row_data << [mode_tos[0], mode_tos[1], guideway_element, 'NA'] + ['']*19
      end
      sheet.add_row row_data.flatten.map{|x| x.to_s}, types: [:string]*5 + [:float]*2 + [:string]*16
    end

    add_performance_restrictions_row(sheet, mode_tos)

  end

  def add_performance_restrictions_row(sheet, mode_tos)
    mode_type = FtaModeType.find_by(code: mode_tos[0])
    service_type = FtaServiceType.find_by(code: mode_tos[1])
    row_data = [] 
    row_data << mode_tos[0] #A
    row_data << mode_tos[1] #B 
    row_data << "Total Track Miles Under Performance Restriction" #C
    row_data << '' #D
    row_data << '' #E
    row_data << '' #F
    row_data << '' #G
    row_data << '' #H
    row_data << '' #I
    row_data << '' #J
    row_data << '' #K
    row_data << '' #L
    row_data << '' #M
    row_data << '' #N
    row_data << '' #O
    row_data << '' #P
    row_data << '' #Q
    row_data << '' #R
    row_data << '' #S
    row_data << '' #T
    row_data << '' #U
    row_data << '' #V
    row_data << '' #W
    # The report has an NtdReportSummary for each combination of FtaModeType and FtaService Type. Grab the Summary for this combo and get the value
    row_data << @ntd_report.ntd_a20_summaries.find_by(fta_mode_type: mode_type, fta_service_type: service_type).try(:monthly_total_average_restrictions_length)
    sheet.add_row row_data

  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
    
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    alphabet = ('A'..'ZZZ').to_a

    # Modes 
    modes = FtaModeType.active
    @modes_end_column = alphabet[modes.count]
    sheet.add_row make_row(modes)

    # Service Types 
    service_types = FtaServiceType.active
    @service_types_end_column = alphabet[service_types.count]
    sheet.add_row make_row(service_types)

    # Guideway Elements
    fta_types = FtaTrackType.active.sorted + FtaGuidewayType.active + FtaPowerSignalType.active + ["Total Track Miles Under Performance Restriction"]
    @fta_types_end_column = alphabet[fta_types.count]
    sheet.add_row make_row(fta_types)

    # Allocation Unit(Row 4)
    allocation_units = ['TM', '%', 'Quantity']
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
    sheet.add_data_validation("L2:L1000",
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
      'Track Miles', #F
      'Expected Service Years When New', #G
      'Percent Agency Capital Responsibility (%)', #H
      'Agency with Shared Responsibility', #I
      'Other Description', #J
      'Notes', #K
      'Allocation Unit', #L
      'Pre-1930', #M
      '1930-1939', #N
      '1940-1949', #O
      '1950-1959', #P
      '1960-1969', #Q
      '1970-1979', #R
      '1980-1989', #S
      '1990-1999', #T
      '2000-2009', #U
      '2010- 2019', #V
      '2020-2029', #W
      'Total Track Miles Under Performance Restriction' #X
    ]

    [detail_row]
  end

  def column_styles
    styles = [
        {:name => 'two-decimal-places', :column => 5},
        {:name => 'two-decimal-places', :column => 6}
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
    a << { name: 'two-decimal-places', format_code: "#,##0.00" }
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
