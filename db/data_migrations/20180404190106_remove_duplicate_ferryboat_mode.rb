class RemoveDuplicateFerryboatMode < ActiveRecord::DataMigration
  def up
    main_ferryboat_mode = FtaModeType.find_by(code: 'FB')

    duplicate_modes = FtaModeType.where(code: 'FB').where.not(id: main_ferryboat_mode.id)

    AssetsFtaModeType.where(fta_mode_type_id: duplicate_modes).update_all(fta_mode_type_id: main_ferryboat_mode.id)

    duplicate_modes.delete_all
  end
end