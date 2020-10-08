require 'rails_helper'

RSpec.describe TransitAsset, type: :model do 

  it { should respond_to :service_status_name, :service_status }

end
