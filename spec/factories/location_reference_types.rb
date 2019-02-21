FactoryBot.define do

  factory :location_reference_type do
    name { "Street Address" }
    format { "ADDRESS" }
    description { "Location is determined by a geocoded street address." }
    active { 1 }
  end
end
