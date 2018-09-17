class CreateContractTypes < ActiveRecord::DataMigration
  def up
    contract_types = [
        {name: 'Contract / PO directly with Vendor', active: true},
        {name: 'Statewide (DOT) Contract / PO', active: true},
        {name: 'Contract / PO from DOT', active: true},
        {name: 'Contract / PO to DOT', active: true}
    ]

    contract_types.each do |type|
      ContractType.create!(type)
    end
  end
end