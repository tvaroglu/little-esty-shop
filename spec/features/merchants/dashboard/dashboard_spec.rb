require 'rails_helper'

RSpec.describe 'Merchants Dashboard Page' do
  before :each do
    @merchant = Merchant.create!(name: 'Tom Holland')
    visit merchant_dashboard_index_path(@merchant.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_dashboard_index_path(@merchant.id))
    expect(page).to have_content("#{@merchant.name}")
  end

  it 'can take the user back one page' do
    click_link 'Return to Index'
    # expect(current_path).to eq('/merchants')
    expect(current_path).to eq(merchants_path)
  end

  it 'can take user to merchant items index page' do
    click_link 'All Items'
    # expect(current_path).to eq("/merchants/#{@merchant.id}/items")
    expect(current_path).to eq(merchant_items_path(@merchant.id))
  end

  it 'can take user to merchant invoice index page' do
    click_link 'All Invoices'
    # expect(current_path).to eq("/merchants/#{@merchant.id}/invoices")
    expect(current_path).to eq(merchant_invoices_path(@merchant.id))
  end

  it 'can take user to merchant discounts index page' do
    click_link 'All Discounts'
    # expect(current_path).to eq("/merchants/#{@merchant.id}/discounts")
    expect(current_path).to eq(merchant_discounts_path(@merchant.id))
  end

end
