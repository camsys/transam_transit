module TransamTransitHelper

  # Returns an array of policy useful miles for vehicles
  def get_max_useful_miles_collection
    a = []
    a << ['100,000', 100000]
    a << ['150,000', 150000]
    a << ['200,000', 200000]
    a << ['250,000', 250000]
    a << ['300,000', 300000]
    a << ['350,000', 350000]
    a << ['400,000', 400000]
    a << ['450,000', 450000]
    a << ['500,000', 500000]
    a << ['550,000', 550000]
    a << ['600,000', 600000]
    a << ['650,000', 650000]
    a << ['700,000', 700000]
    a << ['750,000', 750000]
    a
  end
  # Returns an array of policy useful years for assets
  def get_max_useful_years_collection
    a = []
    (1..40).each do |yr|
      a << [pluralize(yr, 'year'), yr * 12]
    end
    a
  end
end
