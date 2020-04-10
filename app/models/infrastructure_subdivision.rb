class InfrastructureSubdivision < ApplicationRecord

  belongs_to :organization

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    {
      id: id,
      name: name,
      organization: organization.try(:api_json, options)
    }
  end

end
