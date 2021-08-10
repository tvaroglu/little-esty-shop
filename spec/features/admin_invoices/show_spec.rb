require 'rails_helper'

RSpec.describe 'Admin Invoice Show Page' do
  before :each do
    @customer = Customer.create(first_name: 'Tom', last_name: 'Holland')
    @i = Invoice.create!(status: 2, customer_id: @customer.id)
    @merchant1 = Merchant.create!(name: 'Korbanth')
    @discount1 = @merchant1.discounts.create!(quantity_threshold: 5, percentage_discount: 0.25, status: 0)
    @merchant2 = Merchant.create!(name: 'Borkanth')


    @item1 = @merchant1.items.create!(
      name: 'SK2',
      description: "Starkiller's lightsaber from TFU2 promo trailer",
      unit_price: 25_000)
    @item2 = @merchant1.items.create!(
      name: 'Shtok eco',
      description: "Hilt side lit pcb",
      unit_price: 1_500)
    @item3 = @merchant1.items.create!(
      name: 'Hat',
      description: "Signed by MJ",
      unit_price: 60_000)
    @item4 = @merchant2.items.create!(
      name: 'what',
      description: "testy",
      unit_price: 10_000)

    @customer1 = Customer.create!(
      first_name: 'Ben',
      last_name: 'Franklin')

    @invoice1 = @customer1.invoices.create!(status: 0)
    @invoice2 = @customer1.invoices.create!(status: 0)


    @invoice_item1 = InvoiceItem.create!(
      item: @item1,
      invoice: @invoice1,
      quantity: 1,
      unit_price: 1_500,
      status: 0)
    @invoice_item2 = InvoiceItem.create!(
      item: @item2,
      invoice: @invoice1,
      quantity: 1,
      unit_price: 25_000,
      status: 1)
    @invoice_item3 = InvoiceItem.create!(
      item: @item3,
      invoice: @invoice1,
      quantity: 1,
      unit_price: 60_000,
      status: 1)
    @invoice_item4 = InvoiceItem.create!(
      item: @item4,
      invoice: @invoice2,
      quantity: 1,
      unit_price: 60_000,
      status: 1)

    visit admin_invoice_path(@invoice1.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq("/admin/invoices/#{@invoice1.id}")
    expect(page).to have_content("Invoice ID: #{@invoice1.id}")
  end

  it 'displays all of the items on the invoice and only those items' do
    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@item2.name)
    expect(page).to have_content(@item3.name)
    expect(page).to_not have_content(@item4.name)
  end

  describe 'total revenue potential' do
    include ActionView::Helpers
    it 'displays the total revenue generated from all the items on this invoice' do
      expect(page).to have_content("Total Invoice Revenue Potential")
      expect(page).to have_content(@invoice1.invoice_revenue / 100)
    end
    # As an admin
      # When I visit an admin invoice show page
      # Then I see the total revenue from this invoice (not including discounts)
      # And I see the total discounted revenue from this invoice which includes bulk discounts in the calculation
    it 'displays the total discounted revenue generated from all items on the invoice' do
      expect(page).to have_content("Discounted Revenue Potential")
      expect(page).to have_content(number_to_currency(@invoice1.discounted_revenue_for_merchant(@merchant1) / 100.00))
    end
  end

  it 'can update invoice status (happy path)' do
    expect(page).to have_field(:status)

    select "completed", :from => "status"
    click_button("Update Invoice Status")

    expect(current_path).to eq(admin_invoice_path(@invoice1.id))
    expect(page).to have_content("Invoice status successfully updated!")
  end

  it 'can format a date' do
    @item4.created_at = '2021-08-01 14:54:04'
    expected = @item4.format_date(@item4.created_at)

    expect(@item4.format_date(@item4.created_at)).to eq(expected)
  end
end
