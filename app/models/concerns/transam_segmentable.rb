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
    unless self.send(:_from_segment).present? && self.send(:_to_segment).present?
      self.send(:_from_segment) || self.send(:_to_segment)
    end
  end

  def segment
    if self.send(:_from_segment).present? && self.send(:_to_segment).present?
      (self.send(:_from_segment)..self.send(:_to_segment)).step(self.send(:_segment_length))
    end
  end


  def overlaps(instance_id)
    x = self.class.find_by(id: instance_id)
    if x.present?
      if segment.present?
        x.segment.present? ? segment.overlaps?(x.segment) : segment.member?(x.point)
      else
        x.segment.present? ? x.segment.member?(point) : x.point == point
      end
    end
  end

end
