class AddFtaPrivateModeTypes < ActiveRecord::DataMigration
  def up
    [
        {name: 'Shared With Non-Public Mode: Airport, Private Bus Transit'},
        {name: 'Shared With Non-Public Mode: Private Rail Transit'},
        {name: 'Shared With Non-Public Mode: Private Water Transit'}
    ].each do |type|
      if FtaPrivateModeType.find_by(type).nil?
        mode = FtaPrivateModeType.new(type)
        mode.description = mode.name
        mode.active = true
        mode.save!
      end
    end
  end

  def down
    [
        {name: 'Shared With Non-Public Mode: Airport, Private Bus Transit'},
        {name: 'Shared With Non-Public Mode: Private Rail Transit'},
        {name: 'Shared With Non-Public Mode: Private Water Transit'}
    ].each do |type|
      FtaPrivateModeType.find_by(type).destroy!
    end
  end
end