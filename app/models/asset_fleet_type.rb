class AssetFleetType < ActiveRecord::Base
  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    class_name
  end

  def group_by_fields
    standard_group_by_fields + custom_group_by_fields
  end

  def standard_group_by_fields
    groups.split(',')
  end

  def custom_group_by_fields
    custom_groups.split(',')
  end

  def label_fields
    label_groups.split(',')
  end
end
