class RtaApiService

  def get_wo_trans(query)
    uri = URI("https://api.rtafleet.com/graphql")

    unless check_api_key
      return {success: false, response: "API key not found."}
    end

    token = JSON.parse(get_token.body)["access_token"]
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

  def get_all_work_orders
    query = {'query':
             'query {
               getWorkOrderTransactions(tenantId: "RTA02603",facilityId:1,queryOptions:{filters:[{name:"postingDate",operator:GREATER_THAN_OR_EQUAL,values:"2020-10-01"},{name:"postingDate",operator:LESS_THAN_OR_EQUAL,values:"2020-10-31"}]}){
                 meta{
                   totalRecords
                   totalPages
                   limit
                   offset
                   page
                 }
                 workOrderTransactions{
                   facility{
                     id
                   }
                   workOrderLine{
                     workOrder{
                       number
                     }
                     lineNumber
                   }
                   number
                   type
                   postingDate
                   quantity
                   priceWithMarkup
                   totalPriceWithMarkup
                   item{
                     ... on PartPosting{
                       part{
                         ... on NonFilePart{
                           description
                           number
                         }
                                ... on Part{
                           facility{
                             id
                           }
                           partNumber
                           description
                         }
                       }
                     }
                            ... on EmployeePosting{
                       employee{
                         ... on Employee{
                           number
                           name
                         }
                                ... on NonFileEmployee{
                           employeeNumber
                           employeeAbbreviation
                         }
                       }
                     }
                   }
                   createdBy
                 }
               }
             }',
             'variables': {}
            }
    get_wo_trans(query.to_json)
  end

  protected

  def check_api_key
    if ENV['RTA_CLIENT_ID'] && ENV['RTA_CLIENT_SECRET']
      return true
    else
      return false
    end
  end

  private

  def get_token
    uri = URI("https://rtafleet.auth0.com/oauth/token")
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    body = {
        audience: 'https://api.rtafleet.com',
        grant_type: 'client_credentials',
        client_id: ENV['RTA_CLIENT_ID'],
        client_secret: ENV['RTA_CLIENT_SECRET']
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