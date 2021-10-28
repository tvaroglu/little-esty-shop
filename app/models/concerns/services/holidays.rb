module Services
  class Holidays
    def initialize(response_body)
      @response_body = response_body.sort_by { |holiday| holiday['date'] }
    end

    def all_upcoming_holidays
      collection_arr = []
      @response_body.each do |holiday_hash|
        if Date.parse(holiday_hash['date']) >= Date.today
          collection_arr << holiday_hash
        end
      end
      collection_arr
    end

    def next_3
      all_upcoming_holidays.first(3).each_with_object({}) do |holiday_hash, collection_hash|
        holiday = holiday_hash['name']
        date = holiday_hash['date']
        collection_hash[holiday] = date
      end
    end
  end
end
