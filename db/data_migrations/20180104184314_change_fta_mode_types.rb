class ChangeFtaModeTypes < ActiveRecord::DataMigration
  def up
    FtaModeType.find_by(code: 'SR').update!(name: 'Streetcar Rail')
    FtaModeType.find_by(code: 'FB').update!(name: 'Ferryboat')

    FtaModeType.create!(active: true, name: 'Other Vehicles Operated', code: 'OR', description: 'Other Vehicles Operated.')
  end
end