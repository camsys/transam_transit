module TransamSegmentable
  #-----------------------------------------------------------------------------
  #
  # TransamSegmentable
  #
  # Mixin that adds maintenance updates to an Asset
  #
  #-----------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    # Attributes
    #---------------------------------------------------------------------------
    class_attribute :_from_segment, default: "from_segment"
    class_attribute :_to_segment, default: "to_segment"
    class_attribute :_segment_length, default: 0.01


  end

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  module ClassMethods
    def get_segmentable_with_like_line_attributes instance
      where(organization_id: instance.organization_id).where.not(id: instance.id)
    end
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  def point
    unless self.send(_from_segment).present? && self.send(_to_segment).present?
      self.send(_from_segment) || self.send(_to_segment)
    end
  end

  def segment
    if self.send(_from_segment).present? && self.send(_to_segment).present?
      ((self.send(_from_segment))..(self.send(_to_segment)))
    end
  end

  def segment_without_ends
    if self.send(_from_segment).present? && self.send(_to_segment).present?
      ((self.send(_from_segment) + self.send(_segment_length))...(self.send(_to_segment)))
    end
  end


  def overlaps(instance)
    if (instance.class < TransamSegmentable).present?
      if segment.present?
        instance.segment.present? ? segment_without_ends.overlaps?(instance.segment_without_ends) : segment.member?(instance.point)
      else
        instance.segment.present? ? instance.segment.member?(point) : instance.point == point
      end
    else
      false
    end
  end

end
