require 'rails_helper'

RSpec.describe 'Merchants Index Page' do
  before do
    @merchant1 = Merchant.create!(name: 'Tom Holland')
    @merchant2 =  Merchant.create!(name: 'Hol Tommand')
    @merchant3 =  Merchant.create!(name: 'Boss Baby Records')

    visit merchants_path
  end

  it 'is on the correct page' do
    expect(page).to have_current_path(merchants_path, ignore_query: true)
    expect(page).to have_content('Merchants')
  end

  it 'can display all merchants' do
    expect(page).to have_content(@merchant1.name)
    expect(page).to have_content(@merchant2.name)
    expect(page).to have_content(@merchant3.name)
  end

  it 'can take user to merchant dashboard page' do
    within "#merchant-#{@merchant1.id}" do
      click_on 'Merchant Dashboard'
      expect(page).to have_current_path(merchant_dashboard_index_path(@merchant1.id), ignore_query: true)
    end
  end

  it 'can sort merchants by name and updated date' do
    expect(@merchant1.name).to appear_before(@merchant2.name)
    expect(@merchant2.name).to appear_before(@merchant3.name)

    click_on 'Sort Alphabetically'
    expect(page).to have_current_path(merchants_path('name'), ignore_query: true)

    expect(@merchant3.name).to appear_before(@merchant2.name)
    expect(@merchant2.name).to appear_before(@merchant1.name)

    @merchant1.update(name: 'Dom Tolland')
    click_on 'Sort by Updated Date'
    expect(page).to have_current_path(merchants_path('date'), ignore_query: true)
    expect(@merchant1.name).to appear_before(@merchant2.name)
  end
end
