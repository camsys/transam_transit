class UpdateVehicleManufacturers < ActiveRecord::DataMigration
  def up

    # delete duplicate vehicles
    duplicates = Manufacturer.select("id, code, count(id) as quantity").where(filter: 'Vehicle').group(:code).having("quantity > 1")
    duplicates.each do |d|
      manufacturers = Manufacturer.where(filter: 'Vehicle', code: d.code)
      Vehicle.where(manufacturer_id: manufacturers.pluck(:id)).update_all(manufacturer_id: manufacturers.first.id)
      manufacturers.where.not(id: manufacturers.first.id).delete_all
    end

    # delete duplicate Locomotives
    duplicates = Manufacturer.select("id, code, count(id) as quantity").where(filter: 'Locomotive').group(:code).having("quantity > 1")
    duplicates.each do |d|
      manufacturers = Manufacturer.where(filter: 'Locomotive', code: d.code)
      Locomotive.where(manufacturer_id: manufacturers.pluck(:id)).update_all(manufacturer_id: manufacturers.first.id)
      manufacturers.where.not(id: manufacturers.first.id).delete_all
    end

    # delete duplicate SupportVehicle
    duplicates = Manufacturer.select("id, code, count(id) as quantity").where(filter: 'SupportVehicle').group(:code).having("quantity > 1")
    duplicates.each do |d|
      manufacturers = Manufacturer.where(filter: 'SupportVehicle', code: d.code)
      SupportVehicle.where(manufacturer_id: manufacturers.pluck(:id)).update_all(manufacturer_id: manufacturers.first.id)
      manufacturers.where.not(id: manufacturers.first.id).delete_all
    end

    # delete duplicate RailCar
    duplicates = Manufacturer.select("id, code, count(id) as quantity").where(filter: 'RailCar').group(:code).having("quantity > 1")
    duplicates.each do |d|
      manufacturers = Manufacturer.where(filter: 'RailCar', code: d.code)
      RailCar.where(manufacturer_id: manufacturers.pluck(:id)).update_all(manufacturer_id: manufacturers.first.id)
      manufacturers.where.not(id: manufacturers.first.id).delete_all
    end

    manufacturers = [
        {active: 1, code: "AAI", name: "Allen Ashley Inc."},
        {active: 1, code: "ABB", name: "Asea Brown Boveri Ltd."},
        {active: 1, code: "ABI", name: "Advanced Bus Industries"},
        {active: 1, code: "ACF", name: "American Car and Foundry Company"},
        {active: 1, code: "ACI", name: "American Coastal Industries"},
        {active: 1, code: "AEG", name: "AEG Transportation Systems"},
        {active: 1, code: "AII", name: "American Ikarus Inc."},
        {active: 1, code: "ALL", name: "Allen Marine, Inc."},
        {active: 1, code: "ALS", name: "ALSTOM Transport"},
        {active: 1, code: "ALW", name: "ALWEG"},
        {active: 1, code: "ALX", name: "Alexander Dennis Limited"},
        {active: 1, code: "AMD", name: "AMD Marine Consulting Pty Ltd"},
        {active: 1, code: "AMG", name: "AM General Corporation"},
        {active: 1, code: "AMI", name: "Amrail Inc."},
        {active: 1, code: "AMT", name: "AmTran Corporation"},
        {active: 1, code: "ARB", name: "Arboc Mobility LLC"},
        {active: 1, code: "ASK", name: "AAI/Skoda"},
        {active: 1, code: "ATC", name: "American Transportation Corporation"},
        {active: 1, code: "AZD", name: "Azure Dynamics Corporation"},
        {active: 1, code: "BBB", name: " Blue Bird Corporation"},
        {active: 1, code: "BEC", name: " Brookville Equipment Corporation"},
        {active: 1, code: "BFC", name: " Breda Transportation Inc."},
        {active: 1, code: "BIA", name: " Bus Industries of America"},
        {active: 1, code: "BLM", name: " Boise Locomotive Works"},
        {active: 1, code: "BLN", name: " Blount Boats, Inc."},
        {active: 1, code: "BOM", name: " Bombardier Corporation"},
        {active: 1, code: "BOY", name: " Boyertown Auto Body Works"},
        {active: 1, code: "BRA", name: " Braun"},
        {active: 1, code: "BRX", name: " Breaux's Bay Craft, Inc."},
        {active: 1, code: "BUD", name: " Budd Company"},
        {active: 1, code: "BVC", name: " Boeing Vertol Company"},
        {active: 1, code: "BYD", name: " Build Your Dreams, Inc."},
        {active: 1, code: "CAF", name: " Construcciones y Auxiliar de Ferrocarriles (CAF)"},
        {active: 1, code: "CBC", name: " Collins Bus Corporation (form. Collins Industries Inc./COL)"},
        {active: 1, code: "CBR", name: " Carter Brothers"},
        {active: 1, code: "CBW", name: " Carpenter Industries LLC (form. Carpenter Manufacturing Inc.)"},
        {active: 1, code: "CCC", name: " Cable Car Concepts Inc."},
        {active: 1, code: "CCI", name: " Chance Bus Inc. (formerly Chance Manufacturing Company/CHI)"},
        {active: 1, code: "CEQ", name: " Coach and Equipment Manufacturing Company"},
        {active: 1, code: "CHA", name: " Chance Manufacturing Company"},
        {active: 1, code: "CHR", name: " New Chrysler"},
        {active: 1, code: "CMC", name: " Champion Motor Coach Inc."},
        {active: 1, code: "CMD", name: " Chevrolet Motor Division - GMC"},
        {active: 1, code: "CSC", name: " California Street Cable Railroad Company"},
        {active: 1, code: "CVL", name: " Canadian Vickers Ltd."},
        {active: 1, code: "DAK", name: " Dakota Creek Industries, Inc."},
        {active: 1, code: "DER", name: " Derecktor"},
        {active: 1, code: "DHI", name: " Daewoo Heavy Industries"},
        {active: 1, code: "DIA", name: " Diamond Coach Corporation (formerly Coons Mfg. Inc./CMI)"},
        {active: 1, code: "DKK", name: " Double K, Inc. (form. Hometown Trolley)"},
        {active: 1, code: "DMC", name: " Dina/Motor Coach Industries (MCI)"},
        {active: 1, code: "DTD", name: " Dodge Division - Chrysler Corporation"},
        {active: 1, code: "DUC", name: " Dutcher Corporation"},
        {active: 1, code: "DUP", name: " Dupont Industries"},
        {active: 1, code: "DWC", name: " Duewag Corporation"},
        {active: 1, code: "EBC", name: " ElDorado Bus (EBC Inc.)"},
        {active: 1, code: "EBU", name: " Ebus, Inc."},
        {active: 1, code: "EDN", name: " ElDorado National (formerly El Dorado/EBC/Nat. Coach/ NCC"},
        {active: 1, code: "EII", name: " Eagle Bus Manufacturing"},
        {active: 1, code: "ELK", name: " Elkhart Coach (Division of Forest River, Inc.)"},
        {active: 1, code: "FCH", name: " Ferries and Cliff House Railway"},
        {active: 1, code: "FDC", name: " Federal Coach"},
        {active: 1, code: "FIL", name: " Flyer Industries Ltd (aka New Flyer Industries)"},
        {active: 1, code: "FLT", name: " Flxette Corporation"},
        {active: 1, code: "FLX", name: " Flexible Corporation"},
        {active: 1, code: "FRC", name: " Freightliner Corporation"},
        {active: 1, code: "FRD", name: " Ford Motor Corporation"},
        {active: 1, code: "FRE", name: " Freeport Shipbuilding, Inc."},
        {active: 1, code: "FSC", name: " Ferrostaal Corporation"},
        {active: 1, code: "GCA", name: " General Coach America, Inc."},
        {active: 1, code: "GCC", name: " Goshen Coach"},
        {active: 1, code: "GEC", name: " General Electric Corporation"},
        {active: 1, code: "GEO", name: " GEO Shipyard, Inc."},
        {active: 1, code: "GIL", name: " Gillig Corporation"},
        {active: 1, code: "GIR", name: " Girardin Corporation"},
        {active: 1, code: "GLF", name: " Gulf Craft, LLC"},
        {active: 1, code: "GLH", name: " Gladding Hearn"},
        {active: 1, code: "GLV", name: " Glaval Bus"},
        {active: 1, code: "GMC", name: " General Motors Corporation"},
        {active: 1, code: "GML", name: " General Motors of Canada Ltd."},
        {active: 1, code: "GOM", name: " Gomaco"},
        {active: 1, code: "GTC", name: " Gomaco Trolley Company"},
        {active: 1, code: "HIT", name: " Hitachi"},
        {active: 1, code: "HMC", name: " American Honda Motor Company, Inc."},
        {active: 1, code: "HSC", name: " Hawker Siddeley Canada"},
        {active: 1, code: "HYU", name: " Hyundai Rotem"},
        {active: 1, code: "INE", name: " Inekon Group, a.s."},
        {active: 1, code: "INT", name: " International"},
        {active: 1, code: "IRB", name: " Renault & Iveco"},
        {active: 1, code: "JCC", name: " Jewett Car Company"},
        {active: 1, code: "JHC", name: " John Hammond Company"},
        {active: 1, code: "KAW", name: " Kawasaki Rail Car Inc. (formerly Kawasaki Heavy Industries)"},
        {active: 1, code: "KIA", name: " Kia Motors"},
        {active: 1, code: "KIN", name: " Kinki Sharyo USA"},
        {active: 1, code: "KKI", name: " Krystal Koach Inc."},
        {active: 1, code: "MAF", name: " Mafersa"},
        {active: 1, code: "MAN", name: " American MAN Corporation"},
        {active: 1, code: "MBB", name: " M.B.B."},
        {active: 1, code: "MBR", name: " Mahoney Brothers"},
        {active: 1, code: "MBZ", name: " Mercedes Benz"},
        {active: 1, code: "MCI", name: " Motor Coach Industries International (DINA)"},
        {active: 1, code: "MDI", name: " Mid Bus Inc."},
        {active: 1, code: "MER", name: " Ford or individual makes"},
        {active: 1, code: "MKI", name: " American Passenger Rail Car Company (formerly Morrison-Knudsen)"},
        {active: 1, code: "MNA", name: " Mitsibushi Motors; Mitsubishi Motors North America, Inc."},
        {active: 1, code: "MOL", name: " Molly Corporation"},
        {active: 1, code: "MPT", name: " Motive Power Industries (formerly Boise Locomotive)"},
        {active: 1, code: "MSR", name: " Market Street Railway"},
        {active: 1, code: "MTC", name: " Metrotrans Corporation"},
        {active: 1, code: "MVN", name: " Mobility Ventures"},
        {active: 1, code: "NAB", name: " North American Bus Industries Inc. (form. Ikarus USA Inc./IKU)"},
        {active: 1, code: "NAT", name: " North American Transit Inc."},
        {active: 1, code: "NAV", name: " Navistar International Corporation (also known as International/INT)"},
        {active: 1, code: "NBB", name: " Nichols Brothers Boat Builders"},
        {active: 1, code: "NBC", name: " National Mobility Corporation"},
        {active: 1, code: "NCC", name: " National Coach Corporation"},
        {active: 1, code: "NEO", name: " Neoplan  USA Corporation"},
        {active: 1, code: "NFA", name: " New Flyer of America"},
        {active: 1, code: "NIS", name: " Nissan"},
        {active: 1, code: "NOV", name: " NOVA Bus Corporation"},
        {active: 1, code: "OBI", name: " Orion Bus Industries Ltd. (formerly Ontario Bus Industries)"},
        {active: 1, code: "OCC", name: " Overland Custom Coach Inc."},
        {active: 1, code: "OTC", name: " Oshkosh Truck Corporation"},
        {active: 1, code: "PCF", name: " PACCAR (Pacific Car and Foundry Company)"},
        {active: 1, code: "PCI", name: " Prevost Car Inc."},
        {active: 1, code: "PLY", name: " Plymouth Division-Chrysler Corp."},
        {active: 1, code: "PRO", name: " Proterra Inc."},
        {active: 1, code: "PST", name: " Pullman-Standard"},
        {active: 1, code: "PTC", name: " Perley Thomas Car Company"},
        {active: 1, code: "PTE", name: " Port Everglades Yacht & Ship"},
        {active: 1, code: "RHR", name: " Rohr Corporation"},
        {active: 1, code: "RIC", name: " Rico Industries"},
        {active: 1, code: "SBI", name: " SuperBus Inc."},
        {active: 1, code: "SCC", name: " Sabre Bus and Coach Corp. (form. Sabre Carriage Comp.)"},
        {active: 1, code: "SDU", name: " Siemens Mass Transit Division"},
        {active: 1, code: "SFB", name: " Societe Franco-Belge De Material"},
        {active: 1, code: "SFM", name: " San Francisco Muni"},
        {active: 1, code: "SHI", name: " Shepard Brothers Inc."},
        {active: 1, code: "SLC", name: " St. Louis Car Company"},
        {active: 1, code: "SOF", name: " Soferval"},
        {active: 1, code: "SOJ", name: " Sojitz Corporation of America (formerly Nissho Iwai American)"},
        {active: 1, code: "SPC", name: " Startrans (Supreme Corporation)"},
        {active: 1, code: "SPR", name: " Spartan Motors Inc."},
        {active: 1, code: "SSI", name: " Stewart Stevenson Services Inc."},
        {active: 1, code: "STE", name: " Steiner Shipyards, Inc."},
        {active: 1, code: "STR", name: " Starcraft"},
        {active: 1, code: "SUB", name: " Subaru of America or Fuji Heavy Industries Ltd."},
        {active: 1, code: "SUL", name: " Sullivan Bus & Coach Limited"},
        {active: 1, code: "SUM", name: " Sumitomo Corporation"},
        {active: 1, code: "SVM", name: " Specialty Vehicle Manufacturing Corporation"},
        {active: 1, code: "TBB", name: " Thomas Built Buses"},
        {active: 1, code: "TCC", name: " Tokyu Car Company"},
        {active: 1, code: "TEI", name: " Trolley Enterprises Inc."},
        {active: 1, code: "TMC", name: " Transportation Manufacturing Company"},
        {active: 1, code: "TOU", name: " Tourstar"},
        {active: 1, code: "TOY", name: " Toyota Motor Corporation"},
        {active: 1, code: "TRN", name: " Transcoach"},
        {active: 1, code: "TRT", name: " Transteq"},
        {active: 1, code: "TRY", name: " Trolley Enterprises"},
        {active: 1, code: "TTR", name: " Terra Transit"},
        {active: 1, code: "TTT", name: " Turtle Top"},
        {active: 1, code: "USR", name: " US Railcar (formerly Colorado Railcar Manufacturing)"},
        {active: 1, code: "UTD", name: " UTDC Inc."},
        {active: 1, code: "VAN", name: " Van Hool N.V."},
        {active: 1, code: "VOL", name: " Volvo"},
        {active: 1, code: "VTH", name: " VT Halter Marine, Inc. (includes Equitable Shipyards, Inc.)"},
        {active: 1, code: "WAM", name: " Westinghouse-Amrail"},
        {active: 1, code: "WCI", name: " Wheeled Coach Industries Inc."},
        {active: 1, code: "WDS", name: " Washburn & Doughty Associates, Inc."},
        {active: 1, code: "WLH", name: " W. L. Holman Car Company"},
        {active: 1, code: "WOC", name: " Wide One Corporation"},
        {active: 1, code: "WTI", name: " World Trans Inc. (also Mobile-Tech Corporation)"},
        {active: 1, code: "WYC", name: " Wayne Corporation (form. Wayne Manufacturing Company/WAY)"},
        {active: 1, code: "ZZZ", name: " Other (Describe)"}
      ]


    new_manufacturer_ids = []

    # update existing list for vehicle
    manufacturers.each do |m|
      manufacturer = Manufacturer.find_or_initialize_by(code: m[:code], filter: 'Vehicle')
      manufacturer.name = m[:name].strip
      manufacturer.filter = 'Vehicle'
      manufacturer.active = m[:active]
      manufacturer.save!

      unless manufacturer.id.nil?
        new_manufacturer_ids << manufacturer.id
      end

    end

    # update existing list for Locomotive
    manufacturers.each do |m|
      manufacturer = Manufacturer.find_or_initialize_by(code: m[:code], filter: 'Locomotive')
      manufacturer.name = m[:name].strip
      manufacturer.filter = 'Locomotive'
      manufacturer.active = m[:active]
      manufacturer.save!

      unless manufacturer.id.nil?
        new_manufacturer_ids << manufacturer.id
      end

    end

    # update existing list for SupportVehicle
    manufacturers.each do |m|
      manufacturer = Manufacturer.find_or_initialize_by(code: m[:code], filter: 'SupportVehicle')
      manufacturer.name = m[:name].strip
      manufacturer.filter = 'SupportVehicle'
      manufacturer.active = m[:active]
      manufacturer.save!

      unless manufacturer.id.nil?
        new_manufacturer_ids << manufacturer.id
      end

    end

    # update existing list for RailCar
    manufacturers.each do |m|
      manufacturer = Manufacturer.find_or_initialize_by(code: m[:code], filter: 'RailCar')
      manufacturer.name = m[:name].strip
      manufacturer.filter = 'RailCar'
      manufacturer.active = m[:active]
      manufacturer.save!

      unless manufacturer.id.nil?
        new_manufacturer_ids << manufacturer.id
      end

    end

    # puts("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    # new_manufacturer_ids.each { |nmi|
    #   puts("  #{nmi},  ")
    # }
    # puts("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")


    other_manufacturer = Manufacturer.find_by(filter: 'Vehicle', code: 'ZZZ')

    Vehicle.where.not(manufacturer_id: new_manufacturer_ids).each do |asset|
      unless asset.manufacturer.name.include? 'Other'
        asset.other_manufacturer = asset.manufacturer.name
      end
      asset.manufacturer = other_manufacturer

      asset.save!
    end
    Manufacturer.where(filter: 'Vehicle').where.not(id: new_manufacturer_ids).delete_all




    other_manufacturer = Manufacturer.find_by(filter: 'Locomotive', code: 'ZZZ')
    Locomotive.where.not(manufacturer_id: new_manufacturer_ids).each do |asset|
      unless asset.manufacturer.name.include? 'Other'
        asset.other_manufacturer = asset.manufacturer.name
      end
      asset.manufacturer = other_manufacturer

      asset.save!
    end
    Manufacturer.where(filter: 'Locomotive').where.not(id: new_manufacturer_ids).delete_all

    other_manufacturer = Manufacturer.find_by(filter: 'SupportVehicle', code: 'ZZZ')
    SupportVehicle.where.not(manufacturer_id: new_manufacturer_ids).each do |asset|
      unless asset.manufacturer.name.include? 'Other'
        asset.other_manufacturer = asset.manufacturer.name
      end
      asset.manufacturer = other_manufacturer

      asset.save(validate: false)
    end
    Manufacturer.where(filter: 'SupportVehicle').where.not(id: new_manufacturer_ids).delete_all

    other_manufacturer = Manufacturer.find_by(filter: 'RailCar', code: 'ZZZ')
    RailCar.where.not(manufacturer_id: new_manufacturer_ids).each do |asset|
      unless asset.manufacturer.name.include? 'Other'
        asset.other_manufacturer = asset.manufacturer.name
      end
      asset.manufacturer = other_manufacturer

      asset.save!
    end
    Manufacturer.where(filter: 'RailCar').where.not(id: new_manufacturer_ids).delete_all

  end
end