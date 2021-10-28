module APIS
  class RenderRequest
    attr_reader :endpoint, :endpoint_arr

    def initialize(endpoint)
      if endpoint.instance_of?(String)
        @endpoint = endpoint
      else
        @endpoint_arr = endpoint.values
      end
    end

    def parse
      if @endpoint.nil?
        @endpoint_arr.map do |endpoint|
          request = API.make_request(endpoint)
          request.instance_of?(String) ? JSON.parse(request) : JSON.parse(request.body)
        end.flatten
      else
        request = API.make_request(@endpoint)
        request.instance_of?(String) ? JSON.parse(request) : JSON.parse(request.body)
      end
    end
  end
end
