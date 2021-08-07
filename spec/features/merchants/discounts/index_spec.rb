require 'rails_helper'

RSpec.describe 'Merchants Discounts Index Page' do

  before :each do
    @merchant = Merchant.create!(name: 'Tom Holland')
    @discount_1 = Discount.create!(
      quantity_threshold: 5,
      percentage_discount: 0.25,
      merchant_id: @merchant.id)
    @discount_2 = Discount.create!(
      quantity_threshold: 15,
      percentage_discount: 0.75,
      merchant_id: @merchant.id)
    @discount_3 = Discount.create!(
      quantity_threshold: 10,
      percentage_discount: 0.50,
      merchant_id: @merchant.id)

    visit merchant_discounts_path(@merchant.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_discounts_path(@merchant.id))
    expect(page).to have_content("#{@merchant.name}'s Bulk Discounts")
    expect(page).to have_content("All Merchant Discounts")
  end

  it 'displays all bulk discounts and attributes, with a link to the discount show and edit pages' do
    within "#discounts-#{@discount_1.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_1.formatted_percentage} off #{@discount_1.quantity_threshold} items")
      expect(page).to have_link("View Discount")
      expect(page).to have_link("Edit Discount")
    end

    within "#discounts-#{@discount_2.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_2.formatted_percentage} off #{@discount_2.quantity_threshold} items")
      expect(page).to have_link("View Discount")
      expect(page).to have_link("Edit Discount")
    end

    within "#discounts-#{@discount_3.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_3.formatted_percentage} off #{@discount_3.quantity_threshold} items")
      expect(page).to have_link("View Discount")
      expect(page).to have_link("Edit Discount")
    end
  end

end
