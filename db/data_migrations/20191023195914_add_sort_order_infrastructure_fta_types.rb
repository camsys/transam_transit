class AddSortOrderInfrastructureFtaTypes < ActiveRecord::DataMigration
  def up
    [
        ["At-Grade/Ballast (including Expressway)", 1, 'FtaGuidewayType'],
        ["At-Grade/In-Street/Embedded", 2, 'FtaGuidewayType'],
        ["Elevated/Retained Fill", 3, 'FtaGuidewayType'],
        ["Elevated/Concrete", 4, 'FtaGuidewayType'],
        ["Elevated/Steel Viaduct or Bridge", 5, 'FtaGuidewayType'],
        ["Below-Grade/Retained Cut", 6, 'FtaGuidewayType'],
        ["Below-Grade/Cut-and-Cover Tunnel", 7, 'FtaGuidewayType'],
        ["Below-Grade/Bored or Blasted Tunnel", 8, 'FtaGuidewayType'],
        ["Below-Grade/Submerged Tube", 9, 'FtaGuidewayType'],

        ["Tangent - Revenue Service", 15, 'FtaTrackType'],
        ["Curve - Revenue Service", 16, 'FtaTrackType'],
        ["Non-Revenue Service", 17, 'FtaTrackType'],
        ["Double diamond crossover", 19, 'FtaTrackType'],
        ["Single crossover", 20, 'FtaTrackType'],
        ["Half grand union", 21, 'FtaTrackType'],
        ["Single turnout", 22, 'FtaTrackType'],
        ["Grade crossing", 23, 'FtaTrackType'],
        ["Revenue Track - No Capital Replacement Responsibility", 18, 'FtaTrackType'],

        ["Train Control and Signaling", 14, 'FtaPowerSignalType'],
        ["Substation Building", 10, 'FtaPowerSignalType'],
        ["Substation Equipment", 11, 'FtaPowerSignalType'],
        ["Third Rail/Power Distribution", 12, 'FtaPowerSignalType'],
        ["Overhead Contact System/Power Distribution", 13, 'FtaPowerSignalType']
    ].each do |row|
      row[2].constantize.find_by(name: row[0]).update!(sort_order: row[1])
    end
  end
end