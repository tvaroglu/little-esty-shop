require 'rails_helper'

RSpec.describe 'Merchants Invoice show Page' do
  before :each do
    @merchant_1 = Merchant.create!(name: 'Tom Holland')

    @customer_1 = Customer.create!(first_name: 'Green', last_name: 'Goblin')

    @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id)

    @item_1 = Item.create!(name: 'spider suit', description: 'saves lives', unit_price: '10000', merchant_id: @merchant_1.id)
    @item_2 = Item.create!(name: 'web shooter', description: 'shoots webs', unit_price: '5000', merchant_id: @merchant_1.id)
    @item_3 = Item.create!(name: 'upside down kiss', description: 'That Mary jane Swag', unit_price: '15000', merchant_id: @merchant_1.id)

    @inv_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 200, status: 1)

    visit merchant_invoice_path(@merchant_1.id, @invoice_1.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_invoice_path(@merchant_1.id, @invoice_1.id))
  end

  it 'displays invoice attributes' do
    expect(page).to have_content("Invoice ID: #{@invoice_1.id}")
    expect(page).to have_content("#{@invoice_1.status.capitalize}")
    expect(page).to have_content("#{@invoice_1.format_date(@invoice_1.created_at)}")
    expect(page).to have_content("#{@invoice_1.customer.first_name}")
    expect(page).to have_content("#{@invoice_1.customer.last_name}")
  end
end
