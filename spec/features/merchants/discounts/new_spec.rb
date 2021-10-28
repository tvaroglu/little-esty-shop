require 'rails_helper'

RSpec.describe 'The Merchant Discount create page' do
  before do
    @merchant_1 = Merchant.create!(name: 'Korbanth')
    @merchant_2 = Merchant.create!(name: 'Borkanth')
    @discount = @merchant_2.discounts.create!(quantity_threshold: 10, percentage_discount: 0.5)

    @mock_response = [
      { 'date' => '2021-11-11', 'name' => 'Veterans Day' },
      { 'date' => '2021-10-11', 'name' => 'Columbus Day' },
      { 'date' => '2021-09-06', 'name' => 'Labour Day' },
      { 'date' => '2021-07-05', 'name' => 'Independence Day' }
    ]
    allow(ApiService).to receive(:render_request).and_return(@mock_response)

    visit merchant_discounts_path(@merchant_1.id)
  end

  describe 'new bulk discount creation' do
    # As a merchant
      # When I visit my bulk discounts index
      # Then I see a link to create a new discount
      # When I click this link
      # Then I am taken to a new page where I see a form to add a new bulk discount
      # When I fill in the form with valid data
      # Then I am redirected back to the bulk discount index
      # And I see my new bulk discount listed
    it 'prompts the user to fill in all required fields' do
      expect(page).to have_content('Create New Discount')
      expect(page).not_to have_content("#{@discount.formatted_percentage} off")
      expect(page).not_to have_content("#{@discount.quantity_threshold} items")

      click_on 'Create New Discount'
      expect(page).to have_current_path(new_merchant_discount_path(@merchant_1.id), ignore_query: true)

      fill_in('Quantity Threshold:', with: '')
      click_on('Create Discount')
      expect(page).to have_current_path(new_merchant_discount_path(@merchant_1.id), ignore_query: true)
      expect(page).to have_content('All fields are required.')
    end

    it 'creates a new discount if all required fields are populated' do
      expect(page).to have_content('Create New Discount')
      expect(page).not_to have_content("#{@discount.formatted_percentage} off")
      expect(page).not_to have_content("#{@discount.quantity_threshold} items")

      click_on 'Create New Discount'
      expect(page).to have_current_path(new_merchant_discount_path(@merchant_1.id), ignore_query: true)

      fill_in('Quantity Threshold:', with: @discount.quantity_threshold)
      fill_in('Percentage Discount:', with: @discount.percentage_discount)
      click_on('Create Discount')

      expect(page).to have_current_path(merchant_discounts_path(@merchant_1.id), ignore_query: true)

      expect(page).to have_content("#{@discount.formatted_percentage} off")
      expect(page).to have_content("#{@discount.quantity_threshold} items")
    end
  end

  # As a merchant,
    # when I visit the discounts index page,
    # In the Holiday Discounts section, I see a `create discount` button next to each of the 3 upcoming holidays.
    # When I click on the button I am taken to a new discount form that has the form fields auto populated with the following:
      # Discount name: <name of holiday> discount
      # Percentage Discount: 30
      # Quantity Threshold: 2
    # I can leave the information as is, or modify it before saving.
    # I should be redirected to the discounts index page where I see the newly created discount added to the list of discounts.
  it 'links to a pre-populated form to create a new holiday bulk discount' do
    expect(page).not_to have_content('Labour Day Discount')
    within '#holidays-Labour' do
      click_on 'Create New Holiday Discount'
      expect(page).to have_current_path(new_merchant_discount_path(@merchant_1.id, 'Labour Day'), ignore_query: true)
    end

    click_on('Create Discount')

    expect(page).to have_current_path(merchant_discounts_path(@merchant_1.id), ignore_query: true)
    expect(page).to have_content('Labour Day Discount')
    expect(page).to have_content('30% off')
    expect(page).to have_content('2 items')
  end
end
