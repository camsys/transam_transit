class AddTamPolicyMessageTemplateDescriptions < ActiveRecord::DataMigration
  def up
    message_templates = {
        'TamPolicy1' => "A message is sent to the user selected as the 'TAM Group Lead', following the creation of a TAM Group, when a user clicks the 'Generate' button.",
        'TamPolicy2' => "A message is sent to each user with the 'Manager' role at every organization included in a TAM Group, when a user clicks the 'Distribute' button.",
        'TamPolicy3' => "A message is sent to the user selected as the 'TAM Group Lead', following an organization either automatically or manually activating an annual TAM Policy."
    }

    message_templates.each do |name, description|
      MessageTemplate.find_by(name: name).update(description: description)
    end
  end

  def down
    message_templates = {
        'TamPolicy1' => "A message is sent to the user selected as the 'TAM Group Lead', following the creation of a TAM Group, when a user clicks the 'Generate' button.",
        'TamPolicy2' => "A message is sent to each user with the 'Manager' role at every organization included in a TAM Group, when a user clicks the 'Distribute' button.",
        'TamPolicy3' => "A message is sent to the user selected as the 'TAM Group Lead', following an organization either automatically or manually activating an annual TAM Policy."
    }

    message_templates.each do |name, description|
      MessageTemplate.find_by(name: name).update(description: nil)
    end
  end
end