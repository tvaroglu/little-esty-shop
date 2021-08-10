require 'rails_helper'

RSpec.describe "The Merchant Discount create page" do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Korbanth')
    @merchant_2 = Merchant.create!(name: 'Borkanth')
    @discount = @merchant_2.discounts.create!(quantity_threshold: 10, percentage_discount: 0.5)

    @mock_response = [
      {"date"=>"2021-11-11", "name"=>"Veterans Day"},
      {"date"=>"2021-10-11", "name"=>"Columbus Day"},
      {"date"=>"2021-09-06", "name"=>"Labour Day"},
      {"date"=>"2021-07-05", "name"=>"Independence Day"}
    ]
    allow(API).to receive(:render_request).and_return(@mock_response)

    visit merchant_discounts_path(@merchant_1.id)
  end

  # As a merchant
    # When I visit my bulk discounts index
    # Then I see a link to create a new discount
    # When I click this link
    # Then I am taken to a new page where I see a form to add a new bulk discount
    # When I fill in the form with valid data
    # Then I am redirected back to the bulk discount index
    # And I see my new bulk discount listed
  it 'displays a form to create a new bulk discount' do
    expect(page).to have_content("Create New Discount")
    expect(page).to_not have_content("Bulk Discount: #{@discount.formatted_percentage} off #{@discount.quantity_threshold} items")

    click_on 'Create New Discount'
    expect(current_path).to eq(new_merchant_discount_path(@merchant_1.id))

    fill_in('Quantity Threshold:', with: @discount.quantity_threshold)
    fill_in('Percentage Discount:', with: @discount.percentage_discount)
    click_on('Create Discount')

    expect(current_path).to eq(merchant_discounts_path(@merchant_1.id))

    expect(page).to have_content("#{@discount.formatted_percentage} off")
    expect(page).to have_content("#{@discount.quantity_threshold} items")
  end

end
