class InfrastructureComponent < Component
  belongs_to :component_material
  belongs_to :infrastructure_rail_joining
  belongs_to :infrastructure_cap_material
  belongs_to :infrastructure_foundation

end
