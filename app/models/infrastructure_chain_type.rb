class InfrastructureChainType < ApplicationRecord

  # All types that are available
  scope :active, -> { where(:active => true) }


end