# frozen_string_literal: true

class AddAppraisalUpdateAssetEventType < ActiveRecord::DataMigration
  def up
    AssetEventType.create(name: 'Appraisal', class_name: 'AppraisalUpdateEvent', job_name: 'AssetAppraisalUpdateJob', display_icon_name: 'fa fa-dollar', description: 'Appraisal Update', active: 1)
  end
end