class AddComponentSeeds < ActiveRecord::DataMigration
  def up
    component_materials = [
        {name: 'Wooden', component_type: 'Rail', active: true},
        {name: 'Concrete', component_type: 'Rail', active: true},
        {name: 'Steel', component_type: 'Rail', active: true},
        {name: 'Plastic', component_type: 'Rail', active: true},

        {name: 'Asphalt', component_type: 'Surface / Deck', active: true},
        {name: 'Concrete', component_type: 'Surface / Deck', active: true},
        {name: 'Masonry', component_type: 'Surface / Deck', active: true},
        {name: 'Steel', component_type: 'Surface / Deck', active: true},
        {name: 'Timber', component_type: 'Surface / Deck', active: true},

        {name: 'Concrete', component_type: 'Superstructure', active: true},
        {name: 'Iron', component_type: 'Superstructure', active: true},
        {name: 'Masonry', component_type: 'Superstructure', active: true},
        {name: 'Steel', component_type: 'Superstructure', active: true},
        {name: 'Timber', component_type: 'Superstructure', active: true},

        {name: 'Concrete', component_type: 'Substructure', active: true},
        {name: 'Masonry', component_type: 'Substructure', active: true},
        {name: 'Steel', component_type: 'Substructure', active: true},
        {name: 'Timber', component_type: 'Substructure', active: true},
    ]

    component_types= [
        {name: 'Substructure', fta_asset_category: 'Facilities', active:true},
        {name: 'Shell', fta_asset_category: 'Facilities', active:true},
        {name: 'Interior', fta_asset_category: 'Facilities', active:true},
        {name: 'Conveyance', fta_asset_category: 'Facilities', active:true},
        {name: 'Plumbing', fta_asset_category: 'Facilities', active:true},
        {name: 'HVAC', fta_asset_category: 'Facilities', active:true},
        {name: 'Fire Protection', fta_asset_category: 'Facilities', active:true},
        {name: 'Electrical', fta_asset_category: 'Facilities', active:true},
        {name: 'Equipment / Fare Collection', fta_asset_category: 'Facilities', active:true},
        {name: 'Site', fta_asset_category: 'Facilities', active:true},

        {name: 'Rail', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
        {name: 'Ties', fta_asset_category: 'Infrastructure', active: true},
        {name: 'Fasteners', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
        {name: 'Field Welds', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
        {name: 'Joints', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
        {name: 'Ballast', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},

        {name: 'Surface / Deck', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
        {name: 'Superstructure', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
        {name: 'Substructure', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
        {name: 'Track Bed', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
        {name: 'Culverts', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
        {name: 'Perimeter', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    ]

    component_element_types = [
        {name: 'Spikes & Screws', component_type: 'Fasteners', active: true},
        {name: 'Supports', component_type: 'Fasteners', active: true},
        {name: 'Sub-Ballast', component_type: 'Track Bed', active: true},
        {name: 'Blanket', component_type: 'Track Bed', active: true},
        {name: 'Subgrade', component_type: 'Track Bed', active: true},

    ]

    component_subtypes = [
        {name: 'Facilities - Walls', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Foundations - Columns', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Foundations - Pilings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Basement - Materials', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Basement - Insulation', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Basement - Slab', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Basement - Floor Underpinnings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Superstructure / Structural Frame - Columns', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Superstructure / Structural Frame - Pillars', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Superstructure / Structural Frame - Walls', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roof - Surface', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roof - Gutters', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roof - Eaves', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roof - Skylights', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roof - Chimney Surrounds', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Exterior - Windows', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Exterior - Doors', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Exterior - Paint', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Exterior - Masonry', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Shell Appurtenances - Balconies', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Shell Appurtenances - Fire Escapes', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Shell Appurtenances - Gutters', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Shell Appurtenances - Downspouts', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Passenger Areas - Platform', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Passenger Areas - Access Tunnels / Passageways', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Partitions - Walls', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Partitions - Interior Doors', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Partitions - Fittings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Partitions - Signage', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Stairs - Interior Stairs', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Stairs - Landings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Finishes - Materials (walls)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Finishes - Materials (floors)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Finishes - Materials (ceilings)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Finishes - Materials (all surfaces)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Elevators', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Escalators', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Lifts (any type)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Fixtures', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Water Distribution', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Sanitary Waste', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Rain Water Drainage', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Energy Supply', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Heat Generation and Distribution Systems', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Cooling Generation and Distribution Systems', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Testing, Balancing, Controls and Instrumentation', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Chimneys and Vents', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Sprinklers', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Standpipes', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Hydrants and Other Fire Protection Specialties', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Electrical Service & Distribution', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Lighting & Branch Wiring (Interior & Exterior)', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Communications & Security', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Lighting Protection', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Generators', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Emergency Lighting', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Maintenance & Service Equipment', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Turnstiles', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Ticket Machines', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roadways / Driveways', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roadways / Driveways - Signage', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roadways / Driveways - Markings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Roadways / Driveways - Equipment', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Parking Lots', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Parking Lots - Signage', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Parking Lots - Markings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Parking Lots - Equipment', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Pedestrian Areas', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Pedestrian Areas - Signage', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Pedestrian Areas - Markings', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Pedestrian Areas - Equipment', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Site Development - Fences', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Site Development - Walls', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Site Development - Miscellaneous Structures', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Landscaping & Irrigation', parent: {fta_asset_category: 'Facility'}, active:true},
        {name: 'Site Utilities', parent: {fta_asset_category: 'Facility'}, active:true},

        {name: 'Girder Guard Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Block Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Barlow Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Flanged T Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Vignoles Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Double-Headed Rail', parent: {component_type: 'Rail'},active: true},
        {name: 'Bullhead Rail', parent: {component_type: 'Rail'},active: true},

        {name: 'Conventional', parent: {component_type: 'Ties'}, active: true},
        {name: 'Slab', parent: {component_type: 'Ties'}, active: true},
        {name: 'Floating Slab', parent: {component_type: 'Ties'}, active: true},
        {name: 'Y-Shaped', parent: {component_type: 'Ties'}, active: true},
        {name: 'Twin', parent: {component_type: 'Ties'}, active: true},
        {name: 'Wide', parent: {component_type: 'Ties'}, active: true},
        {name: 'Bi-Block', parent: {component_type: 'Ties'}, active: true},
        {name: 'Frame', parent: {component_type: 'Ties'}, active: true},
        {name: 'Ladder', parent: {component_type: 'Ties'}, active: true},

        {name: 'Cut Spike', parent: {component_element_type: 'Spikes & Screws'}, active: true},
        {name: 'Dog Spike', parent: {component_element_type: 'Spikes & Screws'},active: true},
        {name: 'Chair Screw', parent: {component_element_type: 'Spikes & Screws'},active: true},
        {name: 'Fang Bolt', parent: {component_element_type: 'Spikes & Screws'},active: true},
        {name: 'Spring Spike', parent: {component_element_type: 'Spikes & Screws'},active: true},

        {name: 'Rail Chair', parent: {component_element_type: 'Supports'},active: true},
        {name: 'Tie Plate', parent: {component_element_type: 'Supports'},active: true},
        {name: 'Clip', parent: {component_element_type: 'Supports'},active: true},
        {name: 'Tension Clamp', parent: {component_element_type: 'Supports'},active: true},
        {name: 'Bolt Clamp', parent: {component_element_type: 'Supports'},active: true},
        {name: 'Rail Anchor', parent: {component_element_type: 'Supports'},active: true},

        {name: 'Flash Butt', parent: {component_type: 'Field Welds'},active: true},
        {name: 'Gas Pressure', parent: {component_type: 'Field Welds'},active: true},
        {name: 'Thermite', parent: {component_type: 'Field Welds'},active: true},
        {name: 'Enclosed Arc', parent: {component_type: 'Field Welds'},active: true},

        {name: 'Bolted', parent: {component_type: 'Joints'},active: true},
        {name: 'Compromise', parent: {component_type: 'Joints'},active: true},
        {name: 'Bonded (insulated)', parent: {component_type: 'Joints'},active: true},
        {name: 'Bonded (non-insulated)', parent: {component_type: 'Joints'},active: true},
        {name: 'Polyurethane (insulated)', parent: {component_type: 'Joints'},active: true},

        {name: 'Crushed Stone', parent: {component_type: 'Ballast'},active: true},
        {name: 'Concrete (ballastless)', parent: {component_type: 'Ballast'},active: true},


        {name: 'Ballast', parent: {component_type: 'Surface / Deck'},active: true},
        {name: 'Direct Fixation', parent: {component_type: 'Surface / Deck'},active: true},
        {name: 'Embedded', parent: {component_type: 'Surface / Deck'},active: true},
        {name: 'Open', parent: {component_type: 'Surface / Deck'},active: true},

        {name: 'Floor Beams', parent: {component_type: 'Superstructure'},active: true},
        {name: 'Girders', parent: {component_type: 'Superstructure'},active: true},
        {name: 'Stringers', parent: {component_type: 'Superstructure'},active: true},

        {name: 'Abutment', parent: {component_type: 'Substructure'},active: true},
        {name: 'Bent', parent: {component_type: 'Substructure'},active: true},
        {name: 'Pier', parent: {component_type: 'Substructure'},active: true},

        {name: 'Crushed Stone', parent: {component_element_type: 'Sub-Ballast'},active: true},
        {name: 'Gravel', parent: {component_element_type: 'Sub-Ballast'},active: true},
        {name: 'Sand', parent: {component_element_type: 'Sub-Ballast'},active: true},
        {name: 'Slag', parent: {component_element_type: 'Sub-Ballast'},active: true},
        {name: 'Crushed Rock', parent: {component_element_type: 'Blanket'},active: true},
        {name: 'Gravel', parent: {component_element_type: 'Blanket'},active: true},
        {name: 'Manufactured Material', parent: {component_element_type: 'Blanket'},active: true},
        {name: 'Sand', parent: {component_element_type: 'Blanket'},active: true},
        {name: 'Slag', parent: {component_element_type: 'Blanket'},active: true},
        {name: 'Basalt', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Cemented Sedimentary Rocks', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Clay', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Granite', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Gravel', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Igneous Rocks', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Limestone', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Metamorphic Rocks', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Sand', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Sandstone', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Silt', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Slate', parent: {component_element_type: 'Subgrade'},active: true},
        {name: 'Soil', parent: {component_element_type: 'Subgrade'},active: true},

        {name: 'Aluminum', parent: {component_type: 'Culverts'},active: true},
        {name: 'Concrete', parent: {component_type: 'Culverts'},active: true},
        {name: 'High-Density Polyethylene', parent: {component_type: 'Culverts'},active: true},
        {name: 'Plastic', parent: {component_type: 'Culverts'},active: true},
        {name: 'Reinforced Concrete', parent: {component_type: 'Culverts'},active: true},
        {name: 'Steel (pipe)', parent: {component_type: 'Culverts'},active: true},
        {name: 'Stone', parent: {component_type: 'Culverts'},active: true},

        {name: 'Berm', parent: {component_type: 'Perimeter'},active: true},
        {name: 'Noise Barriers', parent: {component_type: 'Perimeter'},active: true},
        {name: 'Security Fencing', parent: {component_type: 'Perimeter'},active: true},

    ]

    ['component_materials', 'component_types', 'component_element_types', 'component_subtypes'].each do |table_name|
      data = eval(table_name)
      data.each do |row|
        x = table_name.classify.constantize.new(row.except(:fta_asset_category, :fta_asset_class, :component_type, :parent))
        ['fta_asset_category', 'fta_asset_class', 'component_type'].each do |assoc|
          x.send("#{assoc}=", assoc.classify.constantize.find_by(name: row[assoc.to_sym])) if row[assoc.to_sym]
        end
        x.parent = row[:parent].first[0].to_s.classify.constantize.find_by(name: row[:parent].first[1]) if row[:parent]

        x.save!
      end
    end
  end

end