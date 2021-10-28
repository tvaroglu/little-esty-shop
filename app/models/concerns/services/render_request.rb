module Services
  class RenderRequest
    attr_reader :endpoint, :endpoint_arr

    def initialize(endpoint)
      if endpoint.instance_of?(String)
        @endpoint = endpoint
      else
        @endpoint_arr = endpoint.values
      end
    end

    def request(endpoint)
      Faraday.get(endpoint)
    end

    def parse(request)
      request.instance_of?(String) ? JSON.parse(request) : JSON.parse(request.body)
    end

    def format
      if @endpoint.nil?
        @endpoint_arr.map do |endpoint|
          parse(request(endpoint))
        end.flatten
      else
        parse(request(endpoint))
      end
    end
  end
end
