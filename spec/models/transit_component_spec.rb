require 'rails_helper'

RSpec.describe TransitComponent, type: :model do 

  it { should respond_to :categorization_name, :type_or_subtype_name }

end
