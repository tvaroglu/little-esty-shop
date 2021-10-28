require 'rails_helper'

RSpec.describe 'Merchants Discounts Index Page' do
  before do
    @merchant = Merchant.create!(name: 'Tom Holland')
    @discount_1 = Discount.create!(
      quantity_threshold: 5,
      percentage_discount: 0.25,
      merchant_id: @merchant.id
    )
    @discount_2 = Discount.create!(
      quantity_threshold: 12,
      percentage_discount: 0.75,
      merchant_id: @merchant.id
    )
    @discount_3 = Discount.create!(
      quantity_threshold: 10,
      percentage_discount: 0.50,
      merchant_id: @merchant.id
    )

    @mock_response = [
      { 'date' => '2021-11-11', 'name' => 'Veterans Day' },
      { 'date' => '2021-10-11', 'name' => 'Columbus Day' },
      { 'date' => '2021-09-06', 'name' => 'Labour Day' },
      { 'date' => '2021-07-05', 'name' => 'Independence Day' }
    ]
    allow(ApiService).to receive(:render_request).and_return(@mock_response)

    visit merchant_discounts_path(@merchant.id)
  end

  it 'is on the correct page' do
    expect(page).to have_current_path(merchant_discounts_path(@merchant.id), ignore_query: true)
    expect(page).to have_content("#{@merchant.name}'s Bulk Discounts")
    expect(page).to have_content('All Merchant Discounts')
  end

  it 'can take the user back to the merchant dashboard' do
    click_on 'Return to Dashboard'
    expect(page).to have_current_path(merchant_dashboard_index_path(@merchant.id), ignore_query: true)
  end

  # As a merchant
    # When I visit my merchant dashboard
    # Then I see a link to view all my discounts
    # When I click this link
    # Then I am taken to my bulk discounts index page
    # Where I see all of my bulk discounts including their
    # percentage discount and quantity thresholds
    # And each bulk discount listed includes a link to its show page
  it 'displays all bulk discounts and attributes, with a link to the discount show and delete actions' do
    expect(@discount_1.status).to eq('enabled')
    expect(@discount_1.status_opposite).to eq('disabled')

    within "#discounts-#{@discount_1.id}" do
      expect(page).to have_content("#{@discount_1.formatted_percentage} off")
      expect(page).to have_content("#{@discount_1.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Delete')
    end

    within "#discounts-#{@discount_2.id}" do
      expect(page).to have_content("#{@discount_2.formatted_percentage} off")
      expect(page).to have_content("#{@discount_2.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Delete')
    end

    within "#discounts-#{@discount_3.id}" do
      expect(page).to have_content("#{@discount_3.formatted_percentage} off")
      expect(page).to have_content("#{@discount_3.quantity_threshold} items")
      expect(page).to have_link('View')
      expect(page).to have_link('Delete')
    end
  end

  it 'redirects the user to the discount show page' do
    within "#discounts-#{@discount_1.id}" do
      click_on('View')
      expect(page).to have_current_path(merchant_discount_path(@merchant.id, @discount_1.id), ignore_query: true)
    end
  end

  # As a merchant
    # When I visit the discounts index page
    # I see a section with a header of "Upcoming Holidays"
    # In this section the name and date of the next 3 upcoming US holidays are listed.
  it 'displays a section for the next 3 upcoming holidays' do
    expected = ApiService.upcoming_holidays
    expect(expected).to eq({
                             'Labour Day' => '2021-09-06',
                             'Columbus Day' => '2021-10-11',
                             'Veterans Day' => '2021-11-11'
                           })

    within '#holidays' do
      expect(page).to have_content('Upcoming Holidays:')
      # save_and_open_page
      expected.each do |holiday, date|
        expect(page).to have_content("#{expected.keys.index(holiday) + 1})")
        expect(page).to have_content("#{holiday}:")
        expect(page).to have_content(@merchant.format_date(Date.parse(date)).to_s)
      end
    end
  end

  # As a merchant
    # When I visit my bulk discounts index
    # Then next to each bulk discount I see a link to delete it
    # When I click this link
    # Then I am redirected back to the bulk discounts index page
    # And I no longer see the discount listed
  it 'displays a link to delete the bulk discount' do
    within "#discounts-#{@discount_1.id}" do
      expect(page).to have_content("#{@discount_1.formatted_percentage} off")
      expect(page).to have_content("#{@discount_1.quantity_threshold} items")
      expect(page).to have_link('Delete')
      # save_and_open_page
      click_on('Delete')
      expect(page).to have_current_path(merchant_discounts_path(@merchant.id), ignore_query: true)
    end

    expect(page).not_to have_content("#{@discount_1.formatted_percentage} off")
    expect(page).not_to have_content("#{@discount_1.quantity_threshold} items")
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
  it 'displays a link to create a new holiday bulk discount' do
    within '#holidays-Labour' do
      # save_and_open_page
      expect(page).to have_link('Create New Holiday Discount')
      click_on 'Create New Holiday Discount'
      expect(page).to have_current_path(new_merchant_discount_path(@merchant.id, 'Labour Day'), ignore_query: true)
    end
  end
end
