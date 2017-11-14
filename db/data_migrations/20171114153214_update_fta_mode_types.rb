class UpdateFtaModeTypes < ActiveRecord::DataMigration
  def up

    types = [
        {code: 'HR', name: 'Heavy Rail', active: true},
        {code: 'CR', name: 'Commuter Rail', active: true},
        {code: 'LR', name: 'Light Rail', active: true},
        {code: 'SR', name: 'Streetcar', active: true},
        {code: 'MG', name: 'Monorail/Automated Guideway', active: true, old_name: 'Monorail/Automated Guideway Transit'},
        {code: 'CC', name: 'Cable Car', active: true},
        {code: 'YR', name: 'Hybrid Rail', active: true},
        {code: 'IP', name: 'Inclined Plain', active: true},
        {code: 'AR', name: 'Alaska Railroad', active: true},
        {code: 'MB', name: 'Bus', active: true},
        {code: 'DR', name: 'Demand Response', active: true},
        {code: 'TB', name: 'Trolleybus', active: true},
        {code: 'CB', name: 'Commuter Bus', active: true},
        {code: 'FB', name: 'Ferryboat', active: true},
        {code: 'RB', name: 'Bus Rapid Transit', active: true},
        {code: 'VP', name: 'Vanpool', active: true},
        {code: 'PB', name: 'Publico', active: true},
        {code: 'DT', name: 'Demand Response Taxi', active: true, old_name: 'Taxi'},
        {code: 'TR', name: 'Aerial Tramway', active: true},
        {code: 'JT', name: 'Jitney', active: true},
        {code: 'XX', name: 'Unknown', active: true}
    ]

    types.each do |type|
      if FtaModeType.find_by(name: type[:old_name] || type[:name]).nil?
        FtaModeType.create!(type.except(:old_name))
      else
        FtaModeType.update!(type.except(:old_name))
      end
    end

    # delete all other modes
    old_modes = FtaModeType.where(code: types.map{|x| x[:code]})
    AssetsFtaModeType.where(fta_mode_type_id: old_modes.ids).update_all(fta_mode_type_id: FtaModeType.find_by(code: 'XX').id)
    old_modes.delete_all

  end
end