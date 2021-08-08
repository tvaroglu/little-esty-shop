require 'rails_helper'

RSpec.describe 'Merchants Invoices index page' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Tom Holland')
    @merchant_2 = Merchant.create!(name: 'Tom Holland')


    @customer_1 = Customer.create!(first_name: 'Green', last_name: 'Goblin')
    @customer_2 = Customer.create!(first_name: 'Green', last_name: 'Goblin')


    @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id)
    @invoice_2 = Invoice.create!(status: 2, customer_id: @customer_1.id)


    @item_1 = Item.create!(name: 'spider suit', description: 'saves lives', unit_price: '10000', merchant_id: @merchant_1.id)
    @item_2 = Item.create!(name: 'web shooter', description: 'shoots webs', unit_price: '5000', merchant_id: @merchant_1.id)
    @item_3 = Item.create!(name: 'upside down kiss', description: 'That Mary jane Swag', unit_price: '15000', merchant_id: @merchant_1.id)

    @inv_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 200, status: 1)
    @inv_item_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_2.id, quantity: 2, unit_price: 200, status: 1)


    visit merchant_invoices_path(@merchant_1.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_invoices_path(@merchant_1.id))
    expect(page).to have_content("Merchant Invoices")
  end

  it 'displays the invoices related to merchant' do
    within("#invoices-#{@invoice_1.id}") do
      expect(page).to have_content("Invoice: #{@invoice_1.id}")
    end
    within("#invoices-#{@invoice_2.id}") do
      expect(page).to have_content("Invoice: #{@invoice_2.id}")
    end
  end

  it 'links to the invoice show page' do
    visit merchant_invoices_path(@merchant_1.id)
    within("#invoices-#{@invoice_1.id}") do
      click_on 'View'
      expect(current_path).to eq(merchant_invoice_path(@merchant_1.id, @invoice_1.id))
    end
  end

end
