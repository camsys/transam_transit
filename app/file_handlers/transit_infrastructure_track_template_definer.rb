class TransitInfrastructureTrackTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  def subtype_column_number
    @subtype_column_number[1]
  end
  def asset_tag_column_number
    @asset_id_column_number[1]
  end
  def setup_instructions()
    instructions = [
        '• Infrastructure - Track tab contains a table where users should enter asset data. Users should enter 1 linear track segment per row and 1 attribute per column',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        # '• Asset IDs and Row Names are frozen to assist in scrolling through the table',
        '• It is recommended that track records be entered for each unique Subtype of linear segment of track. Each individual Subtype segment should consist of the same maximum permissible speed. Should a single Subtype segment consist of differing values of maximum permissible speed, then each segment where the speed differs should be entered as an individual record.',
        "• If track records are being entered for performance restriction reporting only (NTD TAM A-90 requirement), then data entry can be limited to a single entry per each track within a unique Main Line / Division and/or ",
        '• Several Identification and Classification fields are configurable by organization and must be updated prior to conducting an initial Infrastructure - Track bulk upload. These fields include: Main Line / Division; Branch / '
    ]
  end

  def setup_lookup_sheet(wrkb, lookups)
    @lookups = lookups
  end

  def add_columns(sheet, template, org, fta_asset_class, earliest_date)

    dark_green_fill = '6BB14A'
    light_green_fill = '6BB14A'
    grey_fill = 'DBDBDB'
    white_fill = '000000'

    # TODO I almost want to make a class that is just all of these column definitions. Then the builder classes are just a list of calls to make up what is needed
    template.add_column(sheet, 'Organization', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Asset / Segment ID', 'Identification and Classification', {name: 'required_string'})

    template.add_column(sheet, 'External ID', 'Identification and Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Description', 'Identification and Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'From Line', 'Identification and Classification', {name: 'required_string'})

    template.add_column(sheet, 'From', 'Identification and Classification', {name: 'required_string'})

    template.add_column(sheet, 'To Line', 'Identification and Classification', {name: 'required_string'})

    template.add_column(sheet, 'To', 'Identification and Classification', {name: 'required_string'})

    template.add_column(sheet, 'Unit', 'Identification and Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Segment Unit', 'Identification and Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_segment_unit')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Segment Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'From (Location Name)', 'Identification and Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'To (Location Name)', 'Identification and Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Class', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_asset_classes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Type', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Subtype', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('asset_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Subtype',
        :prompt => 'Only values in the list are allowed'})

    # segment
    template.add_column(sheet, 'Segment Type', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_segment_type')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Segment Type',
        :prompt => 'Only values in the list are allowed'})

    # mainline
    template.add_column(sheet, 'Main Line / Division', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('mainline')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Main Line / Division',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Branch / Subdivision', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('branch_subdivisions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Branch / Subdivision',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Track', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('tracks')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Track',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Direction', 'Identification and Classification', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_signal_directions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Direction',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Gauge Type', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_gauge_type')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Gauge Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Gauge', 'Geometry', {name: 'recommended_string'})

    template.add_column(sheet, 'Gauge Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('gauge_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Guauge Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Reference Rail', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_reference_rails')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Reference Rail',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Track Gradient %', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Degree', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Gradient', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Gradient Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_gradient_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Track Gradient Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Horizontal Alignment', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Horizontal Alignment Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Horizontal Alignment Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Vertical Alignment', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Vertical Alignment Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Vertical Alignment Unit',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Crosslevel', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Crosslevel Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Crosslevel Unit',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Warp Parameter', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Warp Parameter Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Warp Parameter Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Track Curvature', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Track Curvature Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_curvature_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Track Curvature Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Cant (Superelevation)', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Cant Unit', 'Geometry', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Cant (Superlative) Unit',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Cant Gradient (Superelevation Runoff)', 'Geometry', {name: 'recommended_string'})
    template.add_column(sheet, 'Cant Gradient Unit', 'Geometry', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('alignment_and_transition_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Cant Gradient (Superelevation Runoff) Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Direct Capital Responsibility', 'Funding', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Direct Capital Responsibility',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, '% Capital Responsibility', 'Funding', {name: 'required_pcnt'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => '0',
        :formula2 => '100',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer between 0 and 100',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '% Capital Responsibility',
        :prompt => 'Only integers between 0 and 100'})


    template.add_column(sheet, 'Organization With Shared Capital Responsibility', 'Funding', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Max Permissible Speed', 'Operations', {name: 'required_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Max Permissible Speed for Track',
        :prompt => 'Enter a whole value only'}, 'default_values', [1])


    template.add_column(sheet, 'Max Permissible Speed Unit', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_max_perm_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Max Permissible Speed Unit',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Primary Mode', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_mode_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Primary Mode',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Service Type (Primary Mode)', 'Operations', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_service_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Type (Primary Mode)',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Land Owner', 'Registration and Title', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, "Land Owner (Other)", 'Registration and Title', {name: 'other_string'})

    template.add_column(sheet, 'Infrastructure Owner', 'Registration and Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, "Infrastructure Owner (Other)", 'Registration and Title', {name: 'last_other_string'})

    template.add_column(sheet, 'Service Status', 'Initial Event Data', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('service_status_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Status',
        :prompt => 'Only values in the list are allowed'})

    post_process(sheet)
  end


  def post_process(sheet)
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = RubyXL::Reference.ind2ref(2,8)
      pane.state = :frozen
      pane.y_split = 2
      pane.x_split = 8
      pane.active_pane = :bottom_right
    end
  end

  def set_columns(asset, cells, columns)
    @add_processing_message = []

    asset.fta_asset_category = FtaAssetCategory.find_by(name: "Infrastructure")

    organization = cells[@agency_column_number[1]].to_s.split(' : ').last
    asset.organization = Organization.find_by(name: organization)

    asset.asset_tag = cells[@asset_id_column_number[1]]
    asset.external_id = cells[@external_id_column_number[1]]
    asset.description = cells[@description_column_number[1]]
    asset.from_line = cells[@line_from_line_column_number[1]]
    asset.from_segment = cells[@line_from_from_column_number[1]]
    asset.to_line = cells[@line_to_line_column_number[1]]
    asset.to_segment = cells[@line_to_to_column_number[1]]
    asset.segment_unit = cells[@unit_column_number[1]]
    asset.infrastructure_segment_unit_type = InfrastructureSegmentUnitType.find_by(name: cells[@unit_segment_column_number[1]])
    asset.from_location_name = cells[@from_location_column_number[1]]
    asset.to_location_name = cells[@to_location_column_number[1]]
    asset.fta_asset_class = FtaAssetClass.find_by(name: cells[@class_column_number[1]])
    asset.fta_type = FtaTrackType.find_by(name: cells[@type_column_number[1]])

    asset_classification =  cells[@subtype_column_number[1]]
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification)

    infrastructure_segment_type = InfrastructureSegmentType.find_by(name: cells[@segment_type_column_number[1]])
    asset.infrastructure_segment_type = infrastructure_segment_type

    mainline = InfrastructureDivision.find_by(name: cells[@mainline_column_number[1]], organization_id: asset.organization.id)
    asset.infrastructure_division = mainline

    branch = InfrastructureSubdivision.find_by(name: cells[@branch_column_number[1]])
    asset.infrastructure_subdivision = branch

    infrastructure_track = InfrastructureTrack.find_by(name: cells[@track_column_number[1]].to_s)
    asset.infrastructure_track = infrastructure_track

    asset.direction = cells[@direction_column_number[1]]

    gauge_type = InfrastructureGaugeType.find_by(name: cells[@gauge_type_column_number[1]])
    asset.infrastructure_gauge_type = gauge_type
    asset.gauge = cells[@guage_column_number[1]]
    asset.gauge_unit = cells[@guage_unit_column_number[1]]

    reference_rail = InfrastructureReferenceRail.find_by(name: cells[@reference_rail_column_number[1]])
    asset.infrastructure_reference_rail = reference_rail

    asset.track_gradient_pcnt = cells[@track_gradient_percent_column_number[1]]
    asset.track_gradient_degree = cells[@track_gradient_percent_degree_column_number[1]]
    asset.track_gradient = cells[@track_gradient_gradient_column_number[1]]
    asset.track_gradient_unit = cells[@track_gradient_unit_column_number[1]]
    asset.horizontal_alignment = cells[@horizontal_alignment_column_number[1]]
    asset.horizontal_alignment_unit = cells[@horizontal_alignment_unit_column_number[1]]
    asset.vertical_alignment = cells[@vertical_alignment_column_number[1]]
    asset.vertical_alignment_unit = cells[@vertical_alignment_unit_column_number[1]]
    asset.crosslevel = cells[@cross_level_column_number[1]]
    asset.crosslevel_unit = cells[@cross_level_unit_column_number[1]]
    asset.warp_parameter = cells[@warp_parameter_column_number[1]]
    asset.warp_parameter_unit = cells[@warp_parameter_unit_column_number[1]]
    asset.track_curvature = cells[@track_curvature_column_number[1]]
    asset.track_curvature_unit = cells[@track_curvature_unit_column_number[1]]
    asset.cant = cells[@cant_superelevation_column_number[1]]
    asset.cant_unit = cells[@cant_superelevation_unit_column_number[1]]
    asset.cant_gradient = cells[@cant_gradient_superelevation_runoff_column_number[1]]
    asset.cant_gradient_unit = cells[@cant_gradient_superelevation_runoff_unit_column_number[1]]

    if (cells[@direct_capital_responsibility_column_number[1]].to_s.upcase == 'YES')
      asset.pcnt_capital_responsibility = cells[@percent_capital_responsibility_column_number[1]].to_i
    end

    organization_with_shared_capital_responsitbility = cells[@organization_with_shared_capital_responsibility_column_number[1]]
    asset.shared_capital_responsibility_organization = Organization.find_by(name: organization_with_shared_capital_responsitbility) unless organization_with_shared_capital_responsitbility.blank?

    asset.max_permissible_speed = cells[@max_permissible_speed_column_number[1]]
    asset.max_permissible_speed_unit = cells[@max_permissible_speed_unit_column_number[1]]

    if !cells[@priamry_mode_column_number[1]].nil?
      priamry_mode_type_string = cells[@priamry_mode_column_number[1]].to_s.split(' - ')[1]
      asset.primary_fta_mode_type = FtaModeType.find_by(name: priamry_mode_type_string)
    else
      @add_processing_message <<  [2, 'danger', "Primary Mode column cannot be blank."]
    end

    if !cells[@service_type_primary_mode_column_number[1]].nil?
      asset.primary_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_primary_mode_column_number[1]])
    else
      @add_processing_message <<  [2, 'danger', "Service Type (Primary Mode) column cannot be blank."]
    end

    land_owner_name = cells[@land_owner_column_number[1]]
    unless land_owner_name.nil?
      asset.land_ownership_organization = Organization.find_by(name: land_owner_name)
      if(land_owner_name == 'Other')
        asset.other_land_ownership_organization = cells[@land_owner_other_column_number[1]]
      end
    end

    infrastructure_owner_name = cells[@infrastructure_owner_column_number[1]]
    unless infrastructure_owner_name.nil?
      asset.title_ownership_organization = Organization.find_by(name: infrastructure_owner_name)
      if(infrastructure_owner_name == 'Other')
        asset.other_title_ownership_organization = cells[@infrastructure_owner_other_column_number[1]]
      end
    end

  end

  def set_events(asset, cells, columns)
    @add_processing_message = []

    unless cells[@service_status_column_number[1]].nil?
      s= ServiceStatusUpdateEventLoader.new
      s.process(asset, [cells[@service_status_column_number[1]], Date.today] )

      event = s.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Status Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end
  end

  def column_widths
    if @organization
      [20] + [30] + [20] * 48
    else
      [30] + [20] * 49
    end

  end

  def worksheet_name
    'Infrastructure - Track'
  end

  def set_initial_asset(cells)
    asset = Track.new

    asset_classification =  cells[@subtype_column_number[1]]
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification)

    asset.asset_tag = cells[@asset_id_column_number[1]]

    asset
  end

  def get_messages_to_process
    @add_processing_message
  end

  def clear_messages_to_process
    @add_processing_message.clear
  end

  private

  def green_label_cells
    green_label_cells = [
        @agency_column_number,
        @asset_id_column_number,
        @line_from_line_column_number,
        @line_from_from_column_number,
        @line_to_line_column_number,
        @line_to_to_column_number,
        @unit_column_number,
        @class_column_number,
        @type_column_number,
        @subtype_column_number,
        @segment_type_column_number,
        @mainline_column_number,
        @branch_column_number,
        @direct_capital_responsibility_column_number,
        @percent_capital_responsibility_column_number,
        @organization_with_shared_capital_responsibility_column_number,
        @priamry_mode_column_number,
        @service_type_primary_mode_column_number,
        @service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
        @external_id_column_number,
        @description_column_number,
        @location_column_number,
        @from_location_column_number,
        @to_location_column_number,
        @number_of_tracks_column_number,
        @bridge_type_column_number,
        @number_of_spans_column_number,
        @number_of_decks_column_number,
        @crossing_column_number,
        @length_1_column_number,
        @length_unit_1_column_number,
        @length_2_column_number,
        @length_unit_2_column_number,
        @length_3_column_number,
        @length_unit_3_column_number,
        @nearest_city_column_number,
        @state_purchase_column_number,
        @land_owner_column_number,
        @infrastructure_owner_column_number
    ]
  end

  def grey_label_cells
    grey_label_cells = [
        @land_owner_other_column_number,
        @infrastructure_owner_other_column_number,
    ]
  end

  def initialize(*args)
    super

    # Define sections
    @identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
    @geometry_column_number = RubyXL::Reference.ref2ind('U1')
    @operations_column_number = RubyXL::Reference.ref2ind('AT1')
    @registartion_column_number = RubyXL::Reference.ref2ind('AX1')
    @funding_column_number =  RubyXL::Reference.ref2ind('AQ1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('BB1')
    @last_known_column_number = RubyXL::Reference.ref2ind('BB1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @external_id_column_number = RubyXL::Reference.ref2ind('C2')
    @description_column_number =  RubyXL::Reference.ref2ind('D2')
    @line_from_line_column_number = RubyXL::Reference.ref2ind('E2')
    @line_from_from_column_number = RubyXL::Reference.ref2ind('F2')
    @line_to_line_column_number = RubyXL::Reference.ref2ind('G2')
    @line_to_to_column_number = RubyXL::Reference.ref2ind('H2')
    @unit_column_number = RubyXL::Reference.ref2ind('I2')
    @unit_segment_column_number = RubyXL::Reference.ref2ind('J2')

    @from_location_column_number = RubyXL::Reference.ref2ind('K2')
    @to_location_column_number = RubyXL::Reference.ref2ind('L2')
    @class_column_number = RubyXL::Reference.ref2ind('M2')
    @type_column_number = RubyXL::Reference.ref2ind('N2')
    @subtype_column_number = RubyXL::Reference.ref2ind('O2')
    @segment_type_column_number = RubyXL::Reference.ref2ind('P2')
    @mainline_column_number = RubyXL::Reference.ref2ind('Q2')
    @branch_column_number = RubyXL::Reference.ref2ind('R2')
    @track_column_number = RubyXL::Reference.ref2ind('S2')
    @direction_column_number = RubyXL::Reference.ref2ind('T2')
    @gauge_type_column_number = RubyXL::Reference.ref2ind('U2')
    @guage_column_number = RubyXL::Reference.ref2ind('V2')
    @guage_unit_column_number = RubyXL::Reference.ref2ind('W2')
    @reference_rail_column_number = RubyXL::Reference.ref2ind('X2')
    @track_gradient_percent_column_number = RubyXL::Reference.ref2ind('Y2')
    @track_gradient_percent_degree_column_number = RubyXL::Reference.ref2ind('Z2')
    @track_gradient_gradient_column_number = RubyXL::Reference.ref2ind('AA2')
    @track_gradient_unit_column_number = RubyXL::Reference.ref2ind('AB2')
    @horizontal_alignment_column_number = RubyXL::Reference.ref2ind('AC2')
    @horizontal_alignment_unit_column_number = RubyXL::Reference.ref2ind('AD2')
    @vertical_alignment_column_number = RubyXL::Reference.ref2ind('AE2')
    @vertical_alignment_unit_column_number = RubyXL::Reference.ref2ind('AF2')
    @cross_level_column_number =	RubyXL::Reference.ref2ind('AG2')
    @cross_level_unit_column_number = RubyXL::Reference.ref2ind('AH2')
    @warp_parameter_column_number = RubyXL::Reference.ref2ind('AI2')
    @warp_parameter_unit_column_number = RubyXL::Reference.ref2ind('AJ2')
    @track_curvature_column_number = RubyXL::Reference.ref2ind('AK2')
    @track_curvature_unit_column_number = RubyXL::Reference.ref2ind('AL2')
    @cant_superelevation_column_number = RubyXL::Reference.ref2ind('AM2')
    @cant_superelevation_unit_column_number = RubyXL::Reference.ref2ind('AN2')
    @cant_gradient_superelevation_runoff_column_number = RubyXL::Reference.ref2ind('AO2')
    @cant_gradient_superelevation_runoff_unit_column_number = RubyXL::Reference.ref2ind('AP2')
    @direct_capital_responsibility_column_number =	RubyXL::Reference.ref2ind('AQ2')
    @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AR2')
    @organization_with_shared_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AS2')
    @max_permissible_speed_column_number = RubyXL::Reference.ref2ind('AT2')
    @max_permissible_speed_unit_column_number = RubyXL::Reference.ref2ind('AU2')
    @priamry_mode_column_number = RubyXL::Reference.ref2ind('AV2')
    @service_type_primary_mode_column_number = RubyXL::Reference.ref2ind('AW2')
    @land_owner_column_number = RubyXL::Reference.ref2ind('AX2')
    @land_owner_other_column_number = RubyXL::Reference.ref2ind('AY2')
    @infrastructure_owner_column_number = RubyXL::Reference.ref2ind('AZ2')
    @infrastructure_owner_other_column_number = RubyXL::Reference.ref2ind('BA2')
    @service_status_column_number = RubyXL::Reference.ref2ind('BB2')
  end


end