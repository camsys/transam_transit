class AddTamPolicyToRuleSets < ActiveRecord::DataMigration
  def up
    RuleSet.create!(name: 'TAM Policy', class_name: 'TamPolicy', active: true)
  end

  def down
    RuleSet.find_by(class_name: 'TamPolicy').destroy!
  end
end