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


    ['infrastructure_segment_types', 'infrastructure_chain_types', 'infrastructure_gauge_types', 'infrastructure_reference_rails', 'infrastructure_rail_joinings', 'infrastructure_tie_forms', 'infrastructure_tie_materials'].each do |table_name|
      data = eval(table_name)
      data.each do |row|
        x = table_name.classify.constantize.new(row)
        x.save!
      end
    end




  end
end