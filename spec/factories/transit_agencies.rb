FactoryGirl.define do
    factory :organization do
    customer_id 1
    address1 '100 Main St'
    city 'Harrisburg'
    state 'PA'
    zip '17120'
    url 'http://www.example.com'
    phone '9999999999'
    grantor_id 1
    organization_type_id 2
    sequence(:name) { |n| "Org #{n}" }
    short_name {name}
    license_holder true
    factory :transit_agency, class: TransitAgency do
      organization_type_id 1
      fta_agency_type_id 1
      fta_service_area_type_id 1
      subrecipient_number 'XXXXXXXXX'
      team_number 'YYYY'
    end
  end
end