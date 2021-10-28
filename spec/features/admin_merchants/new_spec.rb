require 'rails_helper'

RSpec.describe 'Admin New Merchant Page' do
  before do
    visit new_admin_merchant_path
  end

  it 'is on the right page' do
    expect(page).to have_current_path(new_admin_merchant_path, ignore_query: true)
    expect(page).to have_content('New Admin Merchant')
  end

  it 'has a create new merchant form' do
    expect(page).to have_field('Name')
  end

  it 'can create a new merchant' do
    fill_in('Name', with: 'Tom Holland')
    click_button 'Create'
    expect(page).to have_current_path(admin_merchants_path, ignore_query: true)
    expect(page).to have_content('Tom Holland')
    expect(page).to have_content('Tom Holland successfully Created.')
  end

  it 'can throw error when field isnt filled' do
    click_button 'Create'
    expect(page).to have_current_path(new_admin_merchant_path, ignore_query: true)

    expect(page).to have_content("Don't Be Silly! Please Fill Out The Required Fields!")
  end
end
