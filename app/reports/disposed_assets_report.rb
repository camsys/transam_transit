class DisposedAssetsReport < AbstractReport
  include FiscalYear

  KEY_INDEX = [0,2]
  LABELS = ['Disposition Year', 'Flag', 'Organization', 'Asset Count', 'Total Proceeds']
  FORMATS = [:hidden, :string, :string, :integer, :currency]
  DETAIL_LABELS = ['Flag', 'Asset ID', 'Asset Class', 'Asset Type', 'Asset Subtype', 'Federally Funded', 'Disposition Date',
                   'Disposition Type', 'Disposition Proceeds', 'Mileage', 'Condition', 'Age']
  DETAIL_FORMATS = [:string, :string, :string, :string, :string, :boolean, :date, :string, :currency, :integer, :decimal, :integer]

  def initialize(attributes = {})
    super(attributes)
  end

  def get_actions
    @actions = [
      { type: :select,
        where: :start_year,
        values: ['', 2023, 2024, 2025, 2026],
        label: 'From'},
      { type: :select,
        where: :end_year,
        values: ['', 2023, 2024, 2025, 2026],
        label: 'To'},
      { type: :text_field,
        where: :proceeds_threshold,
        label: 'Proceeds At Least $'},
      { type: :select,
        where: :fta_asset_class,
        values: [' '] + FtaAssetClass.pluck(:name),
        label: 'Class'},
      { type: :select,
        where: :asset_type,
        values: ['BU - Bus'],
        label: 'Type'},
      { type: :check_box_collection,
        group: :federally_funded,
        values: ['Federally Funded Only']}
    ]
  end

  def get_data(organization_id_list, params)
    data = [[2026,
             [[2026, '', "Allied Coordinated Transportation Services, Inc", 1, 6851],
              [2026, '&#128681;'.html_safe, "Centre Area Transportation Authority", 3, 29055]]],
            [2025,
             [[2025, '', "Allied Coordinated Transportation Services, Inc", 1, 6851],
              [2025, '&#128681;'.html_safe, "Centre Area Transportation Authority", 3, 29055]]]]
    return {labels: LABELS, data: data, formats: FORMATS}
  end

  def self.get_detail_data(organization_id_list, params)
    data = [['&#128681;'.html_safe, 'BU123', 'Buses (Rubber Tire Vehicles)', 'BU-Bus', 'Bus STD 35 FT', true, '2025-10-20', 'Public Sale', 21055, 219876, 2.0, 12],
            ['', '456', 'Buses (Rubber Tire Vehicles)', 'BU-Bus', 'Bus < 30 FT', false, '2025-09-18', 'Salvage', 3000, 151230, 1.0, 15],
            ['', '789', 'Buses (Rubber Tire Vehicles)', 'BU-Bus', 'Bus < 30 FT', true, '2025-07-21', 'Salvage', 5000, 167891, 1.5, 13]]
    {labels: DETAIL_LABELS, data: data, formats: DETAIL_FORMATS}
  end

  def get_key(row)
    "#{row[KEY_INDEX[0]]}:#{row[KEY_INDEX[1]]}"
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    "#{id}/details#{ext}?key=#{key}"
  end

  def get_detail_view
    "generic_report_detail"
  end

end