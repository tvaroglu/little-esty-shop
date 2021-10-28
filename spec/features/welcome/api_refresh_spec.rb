require 'rails_helper'

RSpec.describe 'Github ApiService Statistics' do
  before do
    visit '/'
    @repo_name = ApiService.repo_name
    @user_names = ApiService.user_names
    @commits = ApiService.contributions[:defaults][:commits]
    @pulls = ApiService.contributions[:defaults][:pulls]
  end

  # As a visitor or an admin user
    # When I visit any page on the site
    # I see the number of commits next to each Github username
    # This number is updated as each member of the team contributes more commits
    # I see the number of merged PRs across all team members
    # This number is updated as each member of the team merges more PRs
  it 'displays the navbar dropdown for ApiService statistics' do
    expect(page).to have_current_path('/')
    expect(page).to have_content('Github Stats')

    click_on('Github Stats')

    within '#dropdownmenu-github' do
      expect(page).to have_link(@repo_name)
      expect(page).to have_content('Total Commits:')
      expect(page).to have_content('Pull Requests:')
      @user_names.values.each do |user_name|
        expect(page).to have_content("#{user_name}: #{@commits[user_name]}")
        expect(page).to have_content("#{user_name}: #{@pulls[user_name]}")
      end
    end
  end

  it 'can refresh ApiService statistics with a redirect back to the current page' do
    mock_response = [
      { 'state' => 'closed', 'title' => 'PR #1',
        'user' => { 'login' => 'tvaroglu' } },
      { 'state' => 'closed', 'title' => 'PR #2',
        'user' => { 'login' => 'AbbottMichael' } },
      { 'state' => 'closed', 'title' => 'PR #3',
        'user' => { 'login' => 'ElliotOlbright' } },
      { 'state' => 'closed', 'title' => 'PR #4',
        'user' => { 'login' => 'bfl3tch' } }
    ]
    allow(Faraday).to receive(:get).and_return(mock_response.to_json)

    click_on('Github Stats')
    within '#dropdownmenu-github' do
      expect(page).to have_link(@repo_name)
      expect(page).to have_content('Total Commits:')
      expect(page).to have_content('Pull Requests:')
      @user_names.values.each do |user_name|
        expect(page).to have_content("#{user_name}: #{@commits[user_name]}")
        expect(page).to have_content("#{user_name}: #{@pulls[user_name]}")
      end
    end

    click_on('Refresh Stats 🔄')
    expect(page).to have_current_path('/')
    expect(page).to have_content('Github ApiService Statistics Successfully Refreshed')

    click_on('Github Stats')
    within '#dropdownmenu-github' do
      @user_names.values.each do |user_name|
        expect(page).to have_content("#{user_name}: 1")
      end
    end
  end

  it 'can display default statistics with a redirect back to the current page if the ApiService rate limit is hit' do
    mock_response = { 'message' => 'ApiService rate limit exceeded' }
    allow(Faraday).to receive(:get).and_return(mock_response.to_json)

    click_on('Github Stats')
    click_on('Refresh Stats 🔄')
    expect(page).to have_current_path('/')
    expect(page).to have_content('Github ApiService Rate Limit Hit, Default Stats Temporarily Rendered')

    click_on('Github Stats')
    within '#dropdownmenu-github' do
      @user_names.values.each do |user_name|
        expect(page).to have_content("#{user_name}: #{@commits[user_name]}")
        expect(page).to have_content("#{user_name}: #{@pulls[user_name]}")
      end
    end
  end
end
