class ReallyMoveAssetsToTransitAssets < ActiveRecord::DataMigration
  def up
    # Sanity check that environment has been fully updated
    if SystemConfigExtension.all.map{|x| (x.class_name.constantize < x.extension_name.constantize).present?}.include? false
      puts "Environment not completely updated."
      puts "Please rerun 'rails data:migrate'"
      exit(false)
    end
    
    # ---------------- fields not mapping properly ----------------- #

    # ************ TransamAsset / TransitAsset *****************
    # manufacturer_model
    # title_owner
    # fta_type

    # ************ Facility *****************
    # facility name
    # facility_size_unit
    # lot size unit
    # ada accessible
    # facility_ownership

    # ************ ServiceVehicle / RevenueVehicle *****************
    # vehicle_length_unit
    # gross_vehicle_weight_unit
    # ada_accessible
    # serial numbers


    # ************ CapitalEquipment / Component *****************
    # quantity_unit
    # serial numbers

    # -------------------------------------------------------------- #

    filename = File.join(TransamTransit::Engine.root,"db/data", 'Asset_TransamAsset_mapping.csv')
    puts "Processing #{filename}"

    other_manufacturer_model = ManufacturerModel.find_by(name: 'Other')
    other_fuel_type = FuelType.find_by(name: 'Other')

    idx = 0
    failed_assets = []
    CSV.foreach(filename, :headers => true, :col_sep => "," ) do |row|

      puts row.inspect

      if row[2] && (row[2].include? '(') && row[0] == 'Revenue Vehicles'
        fta_type_code = row[2][(row[2].index('(')+1)..(row[2].index(')')-1)]
        fta_type_name = row[2][0..(row[2].index('(')-1)].strip
      else
        fta_type_name = row[2]
      end
      if (row[5].include? '(') && row[3] == 'Revenue Vehicles'
        new_fta_type_code = row[5][(row[5].index('(')+1)..(row[5].index(')')-1)]
        new_fta_type_name = row[5][0..(row[5].index('(')-1)].strip
      else
        new_fta_type_name = row[5]
      end

      # get old values we need
      asset_type = AssetType.find_by(name: row[0])
      if asset_type
        asset_subtype = asset_type.asset_subtypes.find_by(name: row[1])
        asset_params = {asset_type: asset_type}
        asset_params[:asset_subtype] = asset_subtype if asset_subtype
        if ['Vehicle', 'RailCar', 'Locomotive'].include? asset_type.class_name
          fta_type = FtaVehicleType.where('name = ? OR code = ?', fta_type_name, fta_type_code).first
          asset_params[:fta_vehicle_type_id] = fta_type.id if fta_type
        elsif asset_type.class_name == 'SupportVehicle'
          fta_type = FtaSupportVehicleType.find_by(name: fta_type_name)
          asset_params[:fta_support_vehicle_type_id] = fta_type.id if fta_type
        elsif ['TransitFacility', 'SupportFacility'].include? asset_type.class_name
          fta_type = FtaFacilityType.find_by(name: fta_type_name)
          asset_params[:fta_facility_type_id] = fta_type.id if fta_type
        end
        assets = Asset.where(asset_params).where.not(id: TransitAsset.select(:asset_id))

        # map
        # and deal with weird fields that don't map properly
        assets.each do |asset|
          # get new values we need
          fta_asset_class = FtaAssetClass.find_by(name: row[4])
          new_klass = fta_asset_class.class_name
          case new_klass
            when "RevenueVehicle"
              fta_type_class = 'FtaVehicleType'
              mapped_fields = {vehicle_length_unit: 'foot', gross_vehicle_weight: (asset.gross_vehicle_weight.to_i > 0 ? asset.gross_vehicle_weight : nil), gross_vehicle_weight_unit: 'pound', ada_accessible: (asset.ada_accessible_lift || asset.ada_accessible_ramp || false), manufacturer_model: other_manufacturer_model}
            when "ServiceVehicle"
              fta_type_class = 'FtaSupportVehicleType'
              mapped_fields = {vehicle_length_unit: 'foot', gross_vehicle_weight: (asset.gross_vehicle_weight.to_i > 0 ? asset.gross_vehicle_weight : nil), gross_vehicle_weight_unit: 'pound', ada_accessible: (asset.ada_accessible_lift || asset.ada_accessible_ramp || false), manufacturer_model: other_manufacturer_model}
            when "Facility"
              fta_type_class = 'FtaFacilityType'
              mapped_fields = {facility_name: asset.description, facility_size_unit: 'square foot', ada_accessible: (asset.ada_accessible_lift || asset.ada_accessible_ramp || false), country: 'US', lot_size: (asset.lot_size.to_i > 0 ? asset.lot_size : nil), lot_size_unit: 'acre'}
            when "CapitalEquipment"
              fta_type_class = 'FtaEquipmentType'
              mapped_fields = {quantity: asset.quantity.to_i > 0 ? asset.quantity : 1, quantity_unit: asset.quantity_units.present? ? asset.quantity_units : 'unit', manufacturer_model: other_manufacturer_model}
          end

          new_fta_type = if new_fta_type_code
                           FtaVehicleType.where('name = ? OR code = ?', new_fta_type_name, new_fta_type_code).first
                         else
                           fta_type_class.constantize.find_by(name: new_fta_type_name)
                         end

          esl_category = EslCategory.find_by(class_name: new_klass, name: row[6]) unless row[6].blank?

          mapped_fields[:esl_category_id] = esl_category.id if esl_category

          mapped_fields = mapped_fields.merge({
                                                  asset_id: asset.id,
                                                  fta_asset_category_id: new_fta_type.fta_asset_class.fta_asset_category_id,
                                                  fta_asset_class_id: new_fta_type.fta_asset_class_id,
                                                  fta_type: new_fta_type,
                                                  other_manufacturer_model: asset.manufacturer_model == other_manufacturer_model ? asset.manufacturer_model : '',
                                                  title_ownership_organization_id: asset.title_owner_organization_id,
                                              })

          # reset fields if values are 0. new validations make sure greater than 0 when makes sense
          mapped_fields = mapped_fields.merge(gross_vehicle_weight: nil) if asset.gross_vehicle_weight && asset.gross_vehicle_weight.to_i == 0


          new_cols = new_klass.constantize.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
          new_asset = new_klass.constantize.new(asset.attributes.slice(*new_cols).merge(mapped_fields))
          new_asset.transam_asset.serial_numbers.build(identification: asset.serial_number) unless asset.serial_number.blank?


          new_asset.generate_object_key(:object_key)
          
          # Build depreciation_entries so we don't spend a lot of time recreating them
          if asset.depreciable
            dep_asset = Asset.get_typed_asset(asset)
            cutoff_date = Date.parse('0100-01-01')
            if new_asset.purchase_date < cutoff_date
              puts "fixing bad dates"
              new_asset.purchase_date += 1900.years
              new_asset.in_service_date += 1900.years if new_asset.in_service_date < cutoff_date
              new_asset.depreciation_start_date += 1900.years if new_asset.depreciation_start_date < cutoff_date
            end
            new_asset.depreciation_entries
              .build(dep_asset.depreciation_entries
                      .collect{|e| e.attributes
                                .slice('event_date', 'description', 'book_value')})
          else
            # puts "new depreciable: #{new_asset.depreciable}"
          end
          
          if asset.object_key == asset.asset_tag
            new_asset.asset_tag = new_asset.object_key
            new_asset.save!(validate: false)
          else
            new_asset.save!(validate: false) # save it so can set modes and service types
            AssetsFtaModeType.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.assets_fta_mode_types.proxy_association.owner.id) if new_asset.respond_to?(:assets_fta_mode_types)
            AssetsFtaServiceType.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.assets_fta_service_types.proxy_association.owner.id)  if new_asset.respond_to?(:assets_fta_service_types)

            unless new_asset.save
              # --------------------------------------------------
              # rules for issues of bad data
              if new_asset.errors.full_messages_for(:fuel_type_id).present? && (['Rail Cars', 'Ferries', 'Other Passenger Vehicles'].include? new_asset.fta_asset_class.name)
                new_asset.fuel_type_id = other_fuel_type.id
                new_asset.other_fuel_type = 'Unpowered'
              end
              if new_asset.errors.full_messages_for(:manufacturer_id).present?
                if asset.asset_type.class_name.include? 'Facility'
                  new_asset.manufacturer_id = Manufacturer.find_by(code: 'ZZZ', filter: 'Equipment').id
                else
                  new_asset.manufacturer_id = Manufacturer.find_by(code: 'ZZZ', filter: asset.asset_type.class_name).id
                end
              end
              new_asset.vehicle_length = 1 if new_asset.errors.full_messages_for(:vehicle_length).present?
              new_asset.seating_capacity = 1 if new_asset.errors.full_messages_for(:seating_capacity).present?
              new_asset.standing_capacity = 1 if new_asset.errors.full_messages_for(:standing_capacity).present?
              new_asset.description = new_asset.asset_tag if new_asset.errors.full_messages_for(:description).present?
              new_asset.serial_number = 'Unknown' if new_asset.errors.full_messages_for(:serial_numbers).present?

              if (new_asset.respond_to? :secondary_fta_mode_types) && (new_asset.secondary_fta_mode_types.include? new_asset.primary_fta_mode_type)
                puts "fixed duplicate modes for: #{new_asset.object_key}"
                new_asset.assets_fta_mode_types.find_by(is_primary: [false, nil], fta_mode_type: new_asset.primary_fta_mode_type).delete
              end
            end

            if new_asset.save
              #
              # associations
              #
              
              # Defined only in transam_asset
              AssetGroupsAsset.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.transam_asset.id)
              # Multiply defined
              # Assumes all update event association declarations follow the convention of
              # :class_name => "#{association_name.singularize.camelize}Event"
              # known exception: :early_disposition_requests instead of :early_diposition_request_updates
              specific_asset = new_asset.very_specific
              asset.asset_events.each do |e|
                assoc_name = e.asset_event_type.class_name.gsub('Event', '').underscore.pluralize
                assoc_name = 'early_disposition_requests' if assoc_name == 'early_disposition_request_updates'
                id = specific_asset.send(assoc_name).proxy_association.owner.id
                e.update_columns(transam_asset_id: id)
              end
              # AssetEvent.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.transam_asset.id)
              # Defined on transit_asset
              # Either use transit_asset if acts_as or very_specific.id if the asset inherits
              # from TransitAsset instead, e.g. CapitalEquipment
              new_id = new_asset.respond_to?(:transit_asset) ?
                         new_asset.transit_asset.id : new_asset.very_specific.id
              AssetsDistrict.where(asset_id: asset.id).update_all(transam_asset_id: new_id)
              # Defined on facility
              AssetsFacilityFeature.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.facility.id) if new_asset.respond_to?(:facility)
              # Defined on revenue_vehicle
              AssetsVehicleFeature.where(asset_id: asset.id).update_all(transam_asset_id: new_asset.revenue_vehicle.id) if new_asset.respond_to?(:revenue_vehicle)


              # move other generic/polymorphic associations like comments/docs/photos
              Comment.where(commentable: asset).each do |thing|
                new_thing = thing.dup
                new_thing.commentable = new_asset.transam_asset
                new_thing.object_key = nil
                new_thing.save!
              end
              Image.where(imagable: asset).each do |thing|
                new_thing = thing.dup
                new_thing.imagable = new_asset.transam_asset
                # Use old object_key for S3
                new_thing.save!(validate: false)
              end
              Document.where(documentable: asset).each do |thing|
                new_thing = thing.dup
                new_thing.documentable = new_asset.transam_asset
                # Use old object_key for S3
                new_thing.save!(validate: false)
              end
              Task.where(taskable: asset).each do |thing|
                new_thing = thing.dup
                new_thing.taskable = new_asset.transam_asset
                new_thing.object_key = nil
                new_thing.save!
              end
            else
              puts "Could not save"
              puts new_asset.inspect
              parent_obj = new_asset.try(:acting_as)
              while parent_obj
                puts parent_obj.inspect
                parent_obj = parent_obj.try(:acting_as)
              end
              puts "#{new_asset.errors.full_messages}"

              failed_assets << [new_asset.organization.short_name, new_asset.asset_subtype.asset_type.name, new_asset.asset_subtype.name, new_asset.fta_type.name, '', '','', new_asset.asset_tag, new_asset.asset_id, new_asset.asset.object_key, new_asset.errors.full_messages]
            end
          end
        end
      end

      idx +=1
    end


    # assets not mapped over to TransamAsset
    bad_assets = Asset.where.not(id: TransitAsset.select(:asset_id)).where.not(id: failed_assets.map{|x| x[8]})
    puts "#{bad_assets.count} assets not mapped to transam_assets"
    bad_assets_categorization = bad_assets
                                    .distinct
                                    .joins(:asset_type, :asset_subtype, :organization)
                                    .joins('LEFT JOIN fta_vehicle_types ON assets.fta_vehicle_type_id = fta_vehicle_types.id')
                                    .joins('LEFT JOIN fta_support_vehicle_types ON assets.fta_support_vehicle_type_id = fta_support_vehicle_types.id')
                                    .joins('LEFT JOIN fta_facility_types ON assets.fta_facility_type_id = fta_facility_types.id')
                                    .pluck('organizations.short_name','asset_types.name', 'asset_subtypes.name', 'fta_vehicle_types.name', 'fta_support_vehicle_types.name', 'fta_facility_types.name', 'assets.asset_tag', 'assets.id', 'assets.object_key')

    CSV.open(File.join(Rails.root,"db/data", 'Asset_TransamAsset_mapping_failures.csv'), "w") do |csv|
      failed_assets.each do |fail|
        csv << fail
      end
      bad_assets_categorization.each do |bad|
        csv << bad
      end
    end

    puts failed_assets.inspect
    puts bad_assets_categorization.inspect

  end
end