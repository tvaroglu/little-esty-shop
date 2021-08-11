require 'rails_helper'

RSpec.describe "The Merchant Discount show page" do
  before :each do
    @merchant = Merchant.create!(name: 'Korbanth')
    @discount_1 = @merchant.discounts.create!(quantity_threshold: 10, percentage_discount: 0.5)

    @item_1 = @merchant.items.create!(
      name: 'SK2',
      description: "Starkiller's lightsaber from TFU2 promo trailer",
      unit_price: 25_000)
    @item_2 = @merchant.items.create!(
      name: 'Shtok eco',
      description: "Hilt side lit pcb",
      unit_price: 1_500)
    @item_3 = @merchant.items.create!(
      name: 'Hat',
      description: "Signed by MJ",
      unit_price: 60_000)

    @customer_1 = Customer.create!(
      first_name: 'Ben',
      last_name: 'Franklin')

    @invoice_1 = @customer_1.invoices.create!(status: 0)
    @invoice_2 = @customer_1.invoices.create!(status: 1)

    @invoice_item1 = InvoiceItem.create!(
      item: @item_1,
      invoice: @invoice_1,
      quantity: 1,
      unit_price: 1_500,
      status: 0)
    @invoice_item_2 = InvoiceItem.create!(
      item: @item_2,
      invoice: @invoice_1,
      quantity: 1,
      unit_price: 25_000,
      status: 1)
    @invoice_item_3 = InvoiceItem.create!(
      item: @item_3,
      invoice: @invoice_2,
      quantity: 1,
      unit_price: 60_000,
      status: 1)
      
    @mock_response = [
      {"date"=>"2021-11-11", "name"=>"Veterans Day"},
      {"date"=>"2021-10-11", "name"=>"Columbus Day"},
      {"date"=>"2021-09-06", "name"=>"Labour Day"},
      {"date"=>"2021-07-05", "name"=>"Independence Day"}
    ]
    allow(API).to receive(:render_request).and_return(@mock_response)

    visit merchant_discount_path(@merchant.id, @discount_1.id)
  end

  # As a merchant
    # When I visit my bulk discount show page
    # Then I see the bulk discount's quantity threshold and percentage discount
  it "displays the bulk discount's quantity threshold and percentage" do
    expect(page).to have_content("Merchant Discount")
    expect(page).to have_content("#{@discount_1.formatted_percentage} off")
    expect(page).to have_content("#{@discount_1.quantity_threshold} items")
  end

  it "displays a link to the bulk discount's edit page" do
    expect(page).to have_link("Edit")
    click_on "Edit"
    expect(current_path).to eq(edit_merchant_discount_path(@merchant.id, @discount_1.id))
  end

  it "displays a link to return to the bulk discounts' index page" do
    expect(page).to have_link('Return to Discounts Index')
    click_on 'Return to Discounts Index'
    expect(current_path).to eq(merchant_discounts_path(@merchant.id))
  end

end
