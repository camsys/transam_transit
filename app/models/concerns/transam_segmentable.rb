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


  def overlaps(instance)
    if (instance.class < TransamSegmentable).present?
      if segment.present?
        instance.segment.present? ? segment.overlaps?(instance.segment) : segment.member?(instance.point)
      else
        instance.segment.present? ? instance.segment.member?(point) : instance.point == point
      end
    else
      false
    end
  end

end
