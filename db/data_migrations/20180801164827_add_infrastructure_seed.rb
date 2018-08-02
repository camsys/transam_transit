class AddInfrastructureSeed < ActiveRecord::DataMigration
  def up
    infrastructure_segment_types = [
        {name: 'Marker Posts', active: true},
        {name: 'Lat / Long', active: true},
        {name: 'Chaining', active: true}
    ]

    infrastructure_chain_types = [
        {name: 'Engineer (100 feet) (30.48 m)', active: true},
        {name: 'Surveyor (66 feet) (20.1168 m)', active: true}
    ]

    infrastructure_gauge_types = [
        {name: 'Standard', active: true},
        {name: 'Broad', active: true},
        {name: 'Narrow', active: true}
    ]

    infrastructure_reference_rails = [
        {name: 'East (North / South Track)', active: true},
        {name: 'North (East / West Track)', active: true},
        {name: 'Outer', active: true},
        {name: 'Center Line', active: true}
    ]

    infrastructure_rail_joinings = [
        {name: 'Jointed Track', active: true},
        {name: 'Continuous Welded Rail', active: true}
    ]

    infrastructure_tie_forms = [
        {name: 'Conventional', active: true},
        {name: 'Slab', active: true},
        {name: 'Floating Slab', active: true},
        {name: 'Y-Shaped', active: true},
        {name: 'Twin', active: true},
        {name: 'Wide', active: true},
        {name: 'Bi-Block', active: true},
        {name: 'Frame', active: true},
        {name: 'Ladder', active: true}
    ]

    infrastructure_tie_materials = [
        {name: 'Wooden', active: true},
        {name: 'Concrete', active: true},
        {name: 'Steel', active: true},
        {name: 'Plastic', active: true},
    ]

    component_types = [
        {name: 'Rail', class_name: 'Infrastructure', active: true},
        {name: 'Tie', class_name: 'Infrastructure', active: true},
        {name: 'Fastening - Spikes & Screws', class_name: 'Infrastructure', active: true},
        {name: 'Fastening - Supports', class_name: 'Infrastructure', active: true},
        {name: 'Field Welds', class_name: 'Infrastructure', active: true},
        {name: 'Joints', class_name: 'Infrastructure', active: true},
        {name: 'Ballast', class_name: 'Infrastructure', active: true},
    ]

    component_subtypes = [
        {name: 'Girder Guard Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Block Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Barlow Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Flanged T Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Vignoles Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Double-Headed Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},
        {name: 'Bullhead Rail', class_name: 'Infrastructure', component_type: 'Rail',active: true},

        {name: 'Cut Spike', class_name: 'Infrastructure', component_type: 'Fastening - Spikes & Screws',active: true},
        {name: 'Dog Spike', class_name: 'Infrastructure', component_type: 'Fastening - Spikes & Screws',active: true},
        {name: 'Chair Screw', class_name: 'Infrastructure', component_type: 'Fastening - Spikes & Screws',active: true},
        {name: 'Fang Bolt', class_name: 'Infrastructure', component_type: 'Fastening - Spikes & Screws',active: true},
        {name: 'Spring Spike', class_name: 'Infrastructure', component_type: 'Fastening - Spikes & Screws',active: true},

        {name: 'Rail Chair', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},
        {name: 'Tie Plate', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},
        {name: 'Clip', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},
        {name: 'Tension Clamp', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},
        {name: 'Bolt Clamp', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},
        {name: 'Rail Anchor', class_name: 'Infrastructure', component_type: 'Fastening - Supports',active: true},

        {name: 'Flash Butt', class_name: 'Infrastructure', component_type: 'Field Welds',active: true},
        {name: 'Gas Pressure', class_name: 'Infrastructure', component_type: 'Field Welds',active: true},
        {name: 'Thermite', class_name: 'Infrastructure', component_type: 'Field Welds',active: true},
        {name: 'Enclosed Arc', class_name: 'Infrastructure', component_type: 'Field Welds',active: true},

        {name: 'Bolted', class_name: 'Infrastructure', component_type: 'Joints',active: true},
        {name: 'Compromise', class_name: 'Infrastructure', component_type: 'Joints',active: true},
        {name: 'Bonded (insulated)', class_name: 'Infrastructure', component_type: 'Joints',active: true},
        {name: 'Bonded (non-insulated)', class_name: 'Infrastructure', component_type: 'Joints',active: true},
        {name: 'Polyurethane (insulated)', class_name: 'Infrastructure', component_type: 'Joints',active: true},

        {name: 'Crushed Stone', class_name: 'Infrastructure', component_type: 'Ballast',active: true},
        {name: 'Concrete (ballastless)', class_name: 'Infrastructure', component_type: 'Ballast',active: true}
    ]


    ['infrastructure_segment_types', 'infrastructure_chain_types', 'infrastructure_gauge_types', 'infrastructure_reference_rails', 'infrastructure_rail_joinings', 'infrastructure_tie_forms', 'infrastructure_tie_materials', 'component_types'].each do |table_name|
      data = eval(table_name)
      data.each do |row|
        x = table_name.classify.constantize.new(row)
        x.save!
      end
    end

    component_subtypes.each do |subtype|
      component_subtype = ComponentSubtype.new(subtype.except(:component_type))
      component_subtype.component_type = ComponentType.find_by(name: subtype[:component_type])
      component_subtype.save!
    end




  end
end