class SegmentableAwareController < OrganizationAwareController

  def get_overlapping
    results = []

    if params[:from_segment] && params[:class_name]

      from_segment = params[:from_segment]
      to_segment = params[:to_segment] unless params[:to_segment].blank?
      segmentable_class = params[:class_name].classify.constantize

      if defined?(segmentable_class) && (segmentable_class < TransamSegmentable).present?
        unless params[:object_key].blank?
          segmentable_instance = segmentable_class.find_by(object_key: params[:object_key])

          segmentable_new = segmentable_class.new
          segmentable_new.send("#{segmentable_class._from_segment}=", from_segment)
          segmentable_new.send("#{segmentable_class._to_segment}=", to_segment) if to_segment

          results = segmentable_instance.get_segmentable_with_like_line_attributes.select { |seg|
            segmentable_new.overlaps(seg)
          }
        end
      end

    end

    respond_to do |format|
      format.json { render json: results.map{|r| [r.object_key, r.to_s]}.to_json }
    end

  end
end
