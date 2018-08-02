class InfrastructureSubdivision < ApplicationRecord

  rails_admin

  # All types that are available
  scope :active, -> { where(:active => true) }


end
