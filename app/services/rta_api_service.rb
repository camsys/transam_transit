class RtaApiService

  def get_data(query, client_id, client_secret)
    uri = URI("https://api.rtafleet.com/graphql")

    unless check_api_key(client_id, client_secret)
      return {success: false, response: "API key not found."}
    end

    token = JSON.parse(get_token(client_id, client_secret).body)["access_token"]
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Host': 'api.rtafleet.com'
    }

    req = Net::HTTP.new(uri.host, uri.port)
    req.use_ssl = true
    response = req.post(uri.path, query, headers)

    return {success: true, response: JSON.parse(response.body)}
  end

  def get_todays_work_orders(tenant_id, facility_id, client_id, client_secret)
    query = {'query':
             'query{
                getWorkOrders(tenantId:"' + tenant_id + '", facilityId: ' + facility_id + ', queryOptions: {
                        filters:[
                            {
                                name:"createdAt"
                                operator:GREATER_THAN_OR_EQUAL
                                values:"' + (Time.now - 24.hours).to_s + '"
                            }
                        ]
                        sort: {
                            sortBy: "finishedAt"
                            sortOrder: asc
                        }
                    })
                    {meta{
                        totalRecords
                        totalPages
                        page
                    }
                    workOrders{
                        finishedAt
                        vehicle{
                            serialNumber
                        }
                        meter
                        lines{
                            vmrs{
                                code
                                description
                            }
                            jobDescription
                            totalEstimatedHours
                            costs{
                                total
                            }
                        }
                    }
                }
            }',
             'variables': {}
            }
    get_data(query.to_json, client_id, client_secret)
  end

  def get_current_vehicle_states(tenant_id, facility_id, client_id, client_secret)
    query = {'query':
                 'query{
                getVehicles(tenantId:"' + tenant_id + '",facilityId:' + facility_id + '){
                    meta{
                        totalRecords
                        totalPages
                        page
                        }
                    vehicles{
                        id
                        vehicleNumber
                        department{
                            number
                            name
                            }
                        classCode
                        make
                        model
                        serialNumber
                        conditionLastUpdated
                        condition{
                            value
                            description
                            }
                        meters{
                            meter{
                                reading
                                unitOfMeasure
                                lastPostedDate
                                }
                            fuelMeter{
                                reading
                                unitOfMeasure
                                lastPostedDate
                                }
                            lifeMeter{
                                reading
                                unitOfMeasure
                                lastPostedDate
                                }
                            }
                        }
                    }
                }',
             'variables': {}
    }
    get_data(query.to_json, client_id, client_secret)
  end

  def get_vehicle_states_all_facilities(tenant_id, client_id, client_secret)
    query = {'query':
                 'query{
              getVehiclesInAllFacilities(tenantId:"' + tenant_id + '"){
                  meta{
                      totalRecords
                      totalPages
                      page
                      }
                  vehicles{
                      id
                      vehicleNumber
                      facility {
                        id
                        name
                        nickname
                        address1
                        address2
                        state
                        postalCode
                        }
                      department{
                          number
                          name
                          }
                      classCode
                      make
                      model
                      serialNumber
                      conditionLastUpdated
                      condition{
                          value
                          description
                          }
                      meters{
                          meter{
                              reading
                              unitOfMeasure
                              lastPostedDate
                              }
                          }
                      }
                  }
              }',
             'variables': {}
    }
    get_data(query.to_json, client_id, client_secret)
  end

  def get_facilities(tenant_id, client_id, client_secret)
    query = {'query':
                 'query{
                getFacilities(tenantId:"' + tenant_id + '",isInactiveFacilitiesIncluded: false){
                  facilities{
                    id
                    name
                    number
                    nickname
                    address1
                  }
                }
              }',
             'variables': {}
    }
    get_data(query.to_json, client_id, client_secret)
  end

  protected

  def check_api_key(client_id, client_secret)
    if client_id && client_secret
      return true
    else
      return false
    end
  end

  private

  def get_token(client_id, client_secret)
    uri = URI("https://rtafleet.auth0.com/oauth/token")
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    body = {
        audience: 'https://api.rtafleet.com',
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
    }

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = headers['Content-Type']
    req.set_form_data(body)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    return response
  end
end