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
    def get_segmentable_with_like_line_attributes(instance, include_self: false)
      if include_self
        where(organization_id: instance.organization_id)
      else
        where(organization_id: instance.organization_id).where.not(id: instance.id)
      end
    end

    def distinct_segments
      original_segments = where.not({_to_segment => nil}).order(_from_segment, _to_segment).map{|x| (x.send(_from_segment)..x.send(_to_segment))}
      distinct_segments = [original_segments.first]

      original_segments[1..-1].each do |rng|
        if rng.overlaps(distinct_segments.last)
          distinct_segments[distinct_segments.length-1] = ([rng.begin, distinct_segments.last.begin].min..[rng.end, distinct_segments.last.end].max)
        else
          distinct_segments << rng
        end
      end

      distinct_segments
    end

    def total_segment_length
      distinct_segments.sum{|segment| segment.end - segment.begin }
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
      ((self.send(_from_segment) + _segment_length)...(self.send(_to_segment)))
    end
  end


  def overlaps(instance)
    if (instance.class < TransamSegmentable).present?
      if segment.present?
        instance.segment.present? ? segment_without_ends.overlaps?(instance.segment_without_ends) : instance.point <= segment.max
      else
        instance.segment.present? ? point <= instance.segment.max : true # a point indicates a starting point for a never ending segment, two points always overlap
      end
    else
      false
    end
  end

end
