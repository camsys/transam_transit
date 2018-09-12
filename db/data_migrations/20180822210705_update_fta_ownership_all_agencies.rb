class UpdateFtaOwnershipAllAgencies < ActiveRecord::DataMigration[5.2]
  def up
    ftas = FtaOwnershipType.all

    updatedFtas = []

    if ftas.length == 5 && ftas.any?{|fta| fta.code == 'OSP'} && ftas.any?{|fta| fta.code == 'OPA'} && ftas.any?{|fta| fta.code == 'LSP'} && ftas.any?{|fta| fta.code == 'LPA'} && ( ftas.any?{|fta| fta.code == 'OR'} || ftas.any?{|fta| fta.code == 'OTHR'} )
      ftas.each {|fta|
        if(fta.code == 'OSP')
          fta.name = 'Owned outright by private entity'
          fta.code = 'OOPE'
          fta.description = 'Owned outright by private entity'
          fta.save
        end
        if(fta.code == 'OPA')
          fta.name = 'Owned outright by public agency'
          fta.code = 'OOPA'
          fta.description = 'Owned outright by public agency'
          fta.save
        end

        if(fta.code == 'LSP')
          fta.name = 'True lease by private entity'
          fta.code = 'TLPE'
          fta.description = 'True lease by private entity'
          fta.save
        end
        if(fta.code == 'LPA')
          fta.name = 'True lease by public agency'
          fta.code = 'TLPA'
          fta.description = 'True lease by public agency'
          fta.save
        end

        if(fta.code == 'OR')
          fta.name = 'Other'
          fta.code = 'OTHR'
          fta.description = 'Other'
          fta.save
        end
      }

      lrpa = FtaOwnershipType.new
      lrpa.name = 'Leased or borrowed from related parties by a public agency'
      lrpa.code = 'LRPA'
      lrpa.description = 'Leased or borrowed from related parties by a public agency'
      lrpa.active = true
      lrpa.save

      lrpe = FtaOwnershipType.new
      lrpe.name = 'Leased or borrowed from related parties by a private entity'
      lrpe.code = 'LRPE'
      lrpe.description = 'Leased or borrowed from related parties by a private entity'
      lrpe.active = true
      lrpe.save

      lppa = FtaOwnershipType.new
      lppa.name = 'Leased under lease purchase agreement by a public agency'
      lppa.code = 'LPPA'
      lppa.description = 'Leased under lease purchase agreement by a public agency'
      lppa.active = true
      lppa.save

      lppe = FtaOwnershipType.new
      lppe.name = 'Leased under lease purchase agreement by a private entity'
      lppe.code = 'LPPE'
      lppe.description = 'Leased under lease purchase agreement by a private entity'
      lppe.active = true
      lppe.save

    else
      puts("Unable to complete this migration. Please ensure that the data has not already been migrated")
    end

  end
end
