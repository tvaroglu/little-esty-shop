require 'rails_helper'

RSpec.describe 'The Merchant Discount edit page' do
  before do
    @merchant = Merchant.create!(name: 'Korbanth')
    @discount_1 = @merchant.discounts.create!(quantity_threshold: 10, percentage_discount: 0.5)

    @item_1 = @merchant.items.create!(
      name: 'SK2',
      description: "Starkiller's lightsaber from TFU2 promo trailer",
      unit_price: 25_000
    )
    @item_2 = @merchant.items.create!(
      name: 'Shtok eco',
      description: 'Hilt side lit pcb',
      unit_price: 1_500
    )
    @item_3 = @merchant.items.create!(
      name: 'Hat',
      description: 'Signed by MJ',
      unit_price: 60_000
    )

    @customer_1 = Customer.create!(
      first_name: 'Ben',
      last_name: 'Franklin'
    )

    @invoice_1 = @customer_1.invoices.create!(status: 0)
    @invoice_2 = @customer_1.invoices.create!(status: 1)

    @invoice_item1 = InvoiceItem.create!(
      item: @item_1,
      invoice: @invoice_1,
      quantity: 1,
      unit_price: 1_500,
      status: 0
    )
    @invoice_item_2 = InvoiceItem.create!(
      item: @item_2,
      invoice: @invoice_1,
      quantity: 1,
      unit_price: 25_000,
      status: 1
    )
    @invoice_item_3 = InvoiceItem.create!(
      item: @item_3,
      invoice: @invoice_2,
      quantity: 1,
      unit_price: 60_000,
      status: 1
    )

    visit edit_merchant_discount_path(@merchant.id, @discount_1.id)
  end

  # As a merchant
    # When I visit my bulk discount show page
    # Then I see a link to edit the bulk discount
    # When I click this link
    # Then I am taken to a new page with a form to edit the discount
    # And I see that the discounts current attributes are pre-poluated in the form
    # When I change any/all of the information and click submit
    # Then I am redirected to the bulk discount's show page
    # And I see that the discount's attributes have been updated
  it 'displays a form to edit the bulk discount' do
    expect(page).to have_content('Editing Merchant Discount')
    expect(@discount_1.quantity_threshold).to eq(10)
    expect(@discount_1.percentage_discount).to eq(0.5)

    fill_in('Quantity Threshold:', with: 11)
    fill_in('Percentage Discount:', with: 0.6)
    click_on('Update Discount')
    expect(page).to have_current_path(merchant_discount_path(@merchant.id, @discount_1.id), ignore_query: true)

    @discount_1.reload
    expect(@discount_1.quantity_threshold).to eq(11)
    expect(@discount_1.percentage_discount).to eq(0.6)
  end
end
