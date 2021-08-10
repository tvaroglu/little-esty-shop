require 'rails_helper'

RSpec.describe "The Merchant Invoice show page" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Korbanth')
    @discount1 = @merchant1.discounts.create!(quantity_threshold: 5, percentage_discount: 0.25, status: 0)
    @discount2 = @merchant1.discounts.create!(quantity_threshold: 2, percentage_discount: 0.10, status: 0)
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
    @invoice2 = @customer1.invoices.create!(status: 1)

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
      invoice: @invoice2,
      quantity: 1,
      unit_price: 60_000,
      status: 1)
    @invoice_item4 = InvoiceItem.create!(
      item: @item4,
      invoice: @invoice2,
      quantity: 1,
      unit_price: 60_000,
      status: 1)
    @invoice_item5 = InvoiceItem.create!(
      item: @item1,
      invoice: @invoice1,
      quantity: 5,
      unit_price: 60_000,
      status: 1)

    visit merchant_invoice_path(@merchant1.id, @invoice1.id)
  end

  it 'is on the correct page' do
    expect(current_path).to eq(merchant_invoice_path(@merchant1.id, @invoice1.id))
  end

  it 'displays the invoice attributes' do
    expect(page).to have_content("Invoice ID: #{@invoice1.id}")
    expect(page).to have_content("#{@invoice1.status.capitalize}")
    expect(page).to have_content("#{@invoice1.format_date(@invoice1.created_at)}")
    expect(page).to have_content("#{@invoice1.customer.first_name}")
    expect(page).to have_content("#{@invoice1.customer.last_name}")
  end

  it 'displays all of the items on the invoice and only those items' do
    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@item2.name)
    expect(page).to_not have_content(@item3.name)
    expect(page).to_not have_content(@item4.name)
  end

  it 'displays the quantity of the item ordered' do
    expect(page).to have_content(@invoice_item1.quantity)
    expect(page).to have_content(@invoice_item2.quantity)
  end

  it 'displays the price that the item sold for' do
    expect(page).to have_content("$15.00")
    expect(page).to have_content("$250.00")
  end

  it 'displays the invoice item status' do
    expect(page).to have_content(@invoice_item1.status)
    expect(page).to have_content(@invoice_item2.status)
  end

  it 'does not display information for items related to other merchants' do
    expect(page).to_not have_content(@item4.name)
  end

  it 'has a dropdown to change the invoice item status' do
    expect(page).to have_button('Update Item Status')
  end

  it 'can update the invoice item status' do
    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@invoice_item1.quantity)

    expect(page).to have_content("$250.00")
    expect(page).to have_content("packaged")

    within("div#id-#{@invoice_item1.id}") do
      select "shipped", :from => "status"
      click_button("Update Item Status")
      @invoice_item1.reload
      expect(page).to have_content("shipped")
    end
    expect(@invoice_item1.status).to eq("shipped")
  end

  describe 'total revenue potential' do
    include ActionView::Helpers
    it 'displays the total revenue generated from all items on the invoice' do
      expect(page).to have_content("Total Invoice Revenue Potential: #{number_to_currency(@invoice1.invoice_revenue / 100.00)}")
    end
    # As a merchant
      # When I visit my merchant invoice show page
      # Then I see the total revenue for my merchant from this invoice (not including discounts)
      # And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation
    it 'displays the total discounted revenue generated from all items on the invoice' do
      expect(page).to have_content("Discounted Revenue Potential: #{number_to_currency(@invoice1.discounted_revenue_for_merchant(@merchant1) / 100.00)}")
    end
  end

  describe 'links to discount show pages' do
    # As a merchant
      # When I visit my merchant invoice show page
      # Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)
    it 'can take the user to the applied discount for each invoite item' do
      within("div#id-#{@invoice_item5.id}") do
        expect(page).to have_content('View Applied Discount')
        click_on 'View Applied Discount'
        expect(current_path).to eq(merchant_discount_path(@merchant1, @discount1))
      end
    end
  end

end
