class ServiceProviderType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    "#{code}-#{name}"
  end

end
