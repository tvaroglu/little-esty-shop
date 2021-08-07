require 'rails_helper'

RSpec.describe "The Merchant Discount show page" do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Korbanth')
    @merchant_2 = Merchant.create!(name: 'asdf')

    @item_1 = @merchant_1.items.create!(
      name: 'SK2',
      description: "Starkiller's lightsaber from TFU2 promo trailer",
      unit_price: 25_000)
    @item_2 = @merchant_1.items.create!(
      name: 'Shtok eco',
      description: "Hilt side lit pcb",
      unit_price: 1_500)
    @item_3 = @merchant_1.items.create!(
      name: 'Hat',
      description: "Signed by MJ",
      unit_price: 60_000)
    @item_4 = @merchant_2.items.create!(
      name: 'what',
      description: "testy",
      unit_price: 10_000)

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
    @invoice_item_4 = InvoiceItem.create!(
      item: @item_4,
      invoice: @invoice_2,
      quantity: 1,
      unit_price: 60_000,
      status: 1)

    visit merchant_invoice_path(@merchant_1.id, @invoice_1.id)
  end

  xit "displays the discounted items for the merchant's discount" do
    # stuff
  end

end
