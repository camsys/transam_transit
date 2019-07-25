class AddMessageTemplatesTamPolicy < ActiveRecord::DataMigration
  def up


    MessageTemplate.create!(name: 'TamPolicy1', delivery_rules: 'When TAM group generated',subject: "TAM Group Generated", body: "The TAM Group: {tam_group}, has been generated for {tam_policy}. You have been designated as the group lead. You must assign metrics for the group, based on asset category and asset class/type/mode. Upon completion, you must distribute group metrics. You can access the group {link(here)}.", active: true, is_implemented: true)
    MessageTemplate.create!(name: 'TamPolicy2', delivery_rules: 'When TAM group distributed', subject: "TAM Group Distributed", body: "The TAM Group: {tam_group}, has been distributed for {tam_policy}. The TAM Group: {tam_group}, has been created in your TAM policy, performance measures section. If you are able to make changes to the performance measures, you may make any changes needed, and activate the performance measures. If you are not allowed to make changes, the performance measures will be activated automatically. You can access the performance measures {link(here)}.", active: true, is_implemented: true)
    MessageTemplate.create!(name: 'TamPolicy3', delivery_rules: 'When TAM group activated', subject: "TAM Performance Measures Activated",  body: "{organization} has activated the TAM performance measures, associated with the TAM Group: {tam_group} for {tam_policy}.You can access the {organization} performance measures {link(here)}.", active: true, is_implemented: true)
  end
end