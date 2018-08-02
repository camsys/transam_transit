class InfrastructureTrack < ApplicationRecord

  def self.include_in_rails_admin
    true
  end

  # All types that are available
  scope :active, -> { where(:active => true) }


end
