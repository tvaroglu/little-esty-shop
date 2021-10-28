require 'rails_helper'

RSpec.describe ApiService do
  describe 'Github API Services' do
    it 'can return the base url and repo name for API calls' do
      expect(ApiService.base_urls[:github]).to eq 'https://api.github.com/repos'

      expect(ApiService.repo_name).to eq 'Little Esty Shop'
    end

    it 'can retrieve contributor user names from contributor endpoints' do
      expected = ApiService.user_names

      expect(expected.class).to eq Hash
      expect(expected.keys.length).to eq 4
      expect(expected.values.length).to eq 4
      expect(expected[:taylor]).to eq 'tvaroglu'
      expect(expected[:michael]).to eq 'AbbottMichael'
      expect(expected[:elliot]).to eq 'ElliotOlbright'
      expect(expected[:brian]).to eq 'bfl3tch'
    end

    it 'can retrieve contribution endpoints and default return values' do
      expected = ApiService.contributions

      expect(expected.class).to eq Hash
      expect(expected.keys.length).to eq 3
      expect(expected.values.length).to eq 3
      expect(expected[:commits]).to eq ApiService.contributors
      expect(expected[:pulls]).to eq(
        'https://api.github.com/repos/bfl3tch/little-esty-shop/pulls?state=closed'
      )
      expect(expected[:defaults][:commits]).to eq(
        { 'tvaroglu' => 57, 'AbbottMichael' => 28, 'ElliotOlbright' => 49, 'bfl3tch' => 40 }
      )
      expect(expected[:defaults][:pulls]).to eq(
        { 'tvaroglu' => 8, 'AbbottMichael' => 6, 'ElliotOlbright' => 10, 'bfl3tch' => 7 }
      )
    end

    it 'can initialize contributor endpoints to parse requests from', :vcr do
      expected = Services::RenderRequest.new(ApiService.contributors)

      expect(expected.endpoint_arr).to eq(ApiService.contributors.values)
    end

    it 'can return a json blob from an API call', :vcr do
      expected = ApiService.render_request(ApiService.contributors[:taylor])

      expect(expected.first.class).to eq Hash
    end

    it 'can aggregate total commits by contributor', :vcr do
      expected = ApiService.aggregate_by_author(:commits)

      expect(expected.class).to eq Hash
      expect(expected.keys.length).to eq 4
      expect(expected.values.length).to eq 4
      expect(expected['tvaroglu'].class).to eq Integer
      expect(expected['AbbottMichael'].class).to eq Integer
      expect(expected['ElliotOlbright'].class).to eq Integer
      expect(expected['bfl3tch'].class).to eq Integer
    end

    it 'can aggregate total pull requests by contributor', :vcr do
      expected = ApiService.aggregate_by_author(:pulls)

      expect(expected.class).to eq Hash
      expect(expected.keys.length).to eq 4
      expect(expected.values.length).to eq 4
      expect(expected['tvaroglu'].class).to eq Integer
      expect(expected['AbbottMichael'].class).to eq Integer
      expect(expected['ElliotOlbright'].class).to eq Integer
      expect(expected['bfl3tch'].class).to eq Integer
    end

    it 'can return an empty hash if the ApiService rate limit is hit' do
      mock_response = { 'message' => 'ApiService rate limit exceeded' }
      allow(ApiService).to receive(:render_request).and_return(mock_response)

      expect(ApiService.aggregate_by_author(:pulls)).to eq({})
      expect(ApiService.aggregate_by_author(:commits)).to eq({})
    end
  end

  describe 'Nager Date API Services' do
    it 'can return the base url for API calls' do
      expected = ApiService.base_urls

      expect(expected[:nager_date]).to eq 'https://date.nager.at'
    end

    it 'can initialize the public holidays endpoint to parse requests from' do
      expected = Services::RenderRequest.new(ApiService.holidays_endpoint)

      expect(expected.endpoint.class).to eq(String)
    end

    it 'can return the next 3 upcoming holidays from the JSON response', :vcr do
      expected = ApiService.upcoming_holidays

      expect(expected.class).to eq Hash
      expect(expected.keys.length).to eq 3
      expect(expected.values.length).to eq 3

      expected.each do |holiday, date|
        expect(holiday.class).to eq String
        expect(date.class).to eq String
      end
    end
  end
end
