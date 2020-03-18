class KeywordSearchIndex < ActiveRecord::Base

	belongs_to		:organization

	#validates			:organization,	:presence => true
	validates     :object_key,		:presence => true
  validates     :object_class,	:presence => true
  validates     :search_text,		:presence => true

	def to_s
		name
	end

	# Return the Rails path to this object
	def name
		if InfrastructureComponent.find_by(object_key: object_key)
			"inventory_path(:id => '#{InfrastructureComponent.find_by(object_key: object_key).parent.object_key}')"
		elsif object_class == Rails.application.config.asset_base_class_name
			"inventory_path(:id => '#{object_key}')"
		else
			"#{object_class.underscore}_path(:id => '#{object_key}')"
		end

	end

end
