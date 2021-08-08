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
    @mock_response = [
      {"date"=>"2021-11-11", "name"=>"Veterans Day"},
      {"date"=>"2021-10-11", "name"=>"Columbus Day"},
      {"date"=>"2021-09-06", "name"=>"Labour Day"},
      {"date"=>"2021-07-05", "name"=>"Independence Day"}
    ]
    allow(API).to receive(:render_request).and_return(@mock_response)

    visit merchant_discounts_path(@merchant.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_discounts_path(@merchant.id))
    expect(page).to have_content("#{@merchant.name}'s Bulk Discounts")
    expect(page).to have_content('All Merchant Discounts')
  end

  it 'can take the user back to the merchant dashboard' do
    click_on 'Return to Dashboard'
    expect(current_path).to eq(merchant_dashboard_index_path(@merchant.id))
  end

  it 'displays all bulk discounts and attributes, with a link to the discount show and edit pages' do
    expect(@discount_1.status).to eq('enabled')
    expect(@discount_1.status_opposite).to eq('disabled')

    within "#discounts-#{@discount_1.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_1.formatted_percentage} off #{@discount_1.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Edit')
    end

    within "#discounts-#{@discount_2.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_2.formatted_percentage} off #{@discount_2.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Edit')
    end

    within "#discounts-#{@discount_3.id}" do
      expect(page).to have_content("Bulk Discount: #{@discount_3.formatted_percentage} off #{@discount_3.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Edit')
    end
  end

  it 'redirects the user to the discount show and edit pages' do
    within "#discounts-#{@discount_1.id}" do
      click_on('View')
      expect(current_path).to eq(merchant_discount_path(@merchant.id, @discount_1.id))
    end

    visit merchant_discounts_path(@merchant.id)
    within "#discounts-#{@discount_1.id}" do
      click_on('Edit')
      expect(current_path).to eq(edit_merchant_discount_path(@merchant.id, @discount_1.id))
    end
  end

  it 'displays a section for the next 3 upcoming holidays' do
    expected = API.upcoming_holidays
    expect(expected).to eq({
      "Labour Day" => "2021-09-06",
      "Columbus Day" => "2021-10-11",
      "Veterans Day" => "2021-11-11"})

    within "#holidays" do
      expect(page).to have_content("Upcoming Holidays:")
      # save_and_open_page
      expected.each do |holiday, date|
        expect(page).to have_content("#{expected.keys.index(holiday) + 1})")
        expect(page).to have_content("#{holiday}:")
        expect(page).to have_content("#{@merchant.format_date(Date.parse(date))}")
      end
    end
  end

end
