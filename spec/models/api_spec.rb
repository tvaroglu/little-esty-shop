require 'rails_helper'

RSpec.describe API do
  it 'exists' do
    api = API.new

    expect(api.class).to eq(API)
    expect(API.repo_name).to eq('Little Esty Shop')
  end

  describe 'Github APIs' do
    it 'can retrieve contributor user names from contributor endpoints' do
      expected = API.user_names

      expect(expected.class).to eq(Hash)
      expect(expected.keys.length).to eq(4)
      expect(expected.values.length).to eq(4)
      expect(expected[:taylor]).to eq('tvaroglu')
      expect(expected[:michael]).to eq('AbbottMichael')
      expect(expected[:elliot]).to eq('ElliotOlbright')
      expect(expected[:brian]).to eq('bfl3tch')
    end

    it 'can retrieve contribution endpoints and default return values' do
      expected = API.contributions

      expect(expected.class).to eq(Hash)
      expect(expected.keys.length).to eq(3)
      expect(expected.values.length).to eq(3)
      expect(expected[:commits]).to eq(API.contributors)
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

    it 'can initialize contributor endpoints to parse requests' do
      mock_response = [
        { 'sha' => '12345',
          'committer' => { 'name' => 'GitHub', 'email' => 'noreply@github.com' },
          'author' => { 'login' => 'tvaroglu', 'id' => 12_345 } }
      ]
      expected = APIS::RenderRequest.new(API.contributors)
      expect(expected.endpoint_arr).to eq(API.contributors.values)

      allow(API).to receive(:make_request).and_return(mock_response.first.to_json)
      expect(expected.parse.first).to eq(mock_response.first)
    end

    it 'can return a json blob from an API call' do
      mock_response = '{"login":"tvaroglu","id":58891447,"url":"https://api.github.com/users/tvaroglu"}'
      allow(Faraday).to receive(:get).and_return(mock_response)

      expected = API.render_request(API.contributors[:taylor])
      expect(expected['login']).to eq('tvaroglu')
    end

    it 'can aggregate total commits by contributor' do
      mock_response = [
        { 'sha' => '12345',
          'committer' => { 'name' => 'GitHub', 'email' => 'noreply@github.com' },
          'author' => { 'login' => 'tvaroglu', 'id' => 12_345 } },
        { 'sha' => '67891',
          'committer' => { 'name' => 'GitHub', 'email' => 'noreply@github.com' },
          'author' => { 'login' => 'bfl3tch', 'id' => 67_891 } },
        { 'sha' => '23456',
          'committer' => { 'name' => 'GitHub', 'email' => 'noreply@github.com' },
          'author' => { 'login' => 'tvaroglu', 'id' => 23_456 } }
      ]

      allow(API).to receive(:render_request).and_return(mock_response)
      expected = API.aggregate_by_author(:commits)

      expect(expected.class).to eq(Hash)
      expect(expected.keys.length).to eq(2)
      expect(expected.values.length).to eq(2)
      expect(expected['tvaroglu']).to eq(2)
      expect(expected['bfl3tch']).to eq(1)
    end

    it 'can aggregate total pull requests by contributor' do
      mock_response = [
        { 'state' => 'closed', 'title' => 'PR #1',
          'user' => { 'login' => 'ElliotOlbright' } },
        { 'state' => 'closed', 'title' => 'PR #2',
          'user' => { 'login' => 'bfl3tch' } },
        { 'state' => 'closed', 'title' => 'PR #3',
          'user' => { 'login' => 'ElliotOlbright' } }
      ]
      allow(API).to receive(:render_request).and_return(mock_response)
      expected = API.aggregate_by_author(:pulls)

      expect(expected.class).to eq(Hash)
      expect(expected.keys.length).to eq(2)
      expect(expected.values.length).to eq(2)
      expect(expected['ElliotOlbright']).to eq(2)
      expect(expected['bfl3tch']).to eq(1)
    end

    it 'can return an empty hash if the API rate limit is hit' do
      mock_response = { 'message' => 'API rate limit exceeded' }
      allow(API).to receive(:render_request).and_return(mock_response)

      expect(API.aggregate_by_author(:pulls)).to eq({})
      expect(API.aggregate_by_author(:commits)).to eq({})
    end
  end

  describe 'Nager Date APIs' do
    it 'can retrieve the public holidays endpoint for API calls' do
      expect(API.nager_date_endpoint).to eq('https://date.nager.at/api/v1/Get/US/2021')
    end

    it 'can call the public holidays endpoint to return a JSON response' do
      expected = APIS::RenderRequest.new(API.nager_date_endpoint)
      expect(expected.endpoint.class).to eq(String)
    end

    it 'can return the next 3 upcoming holidays from the JSON response' do
      mock_response = [
        { 'date' => '2021-11-11', 'name' => 'Veterans Day' },
        { 'date' => '2021-10-11', 'name' => 'Columbus Day' },
        { 'date' => '2021-09-06', 'name' => 'Labour Day' },
        { 'date' => '2021-07-05', 'name' => 'Independence Day' }
      ]
      allow(API).to receive(:render_request).and_return(mock_response)

      expect(API.upcoming_holidays).to eq({
                                            'Labour Day' => '2021-09-06',
                                            'Columbus Day' => '2021-10-11',
                                            'Veterans Day' => '2021-11-11'
                                          })
    end
  end
end
