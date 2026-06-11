class VinService
  def decode_vin(vin)
    base_uri = URI("https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/#{vin}?format=json")
    response = Net::HTTP.get(base_uri)
    data = JSON.parse(response)
    returned_fields = ["Suggested VIN", "Error Code", "Error Text"]
    lookup_results = data["Results"].select{|result| returned_fields.include? result["Variable"]}
    return lookup_results
  end
end