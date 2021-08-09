require 'rails_helper'

RSpec.describe Invoice do
  describe 'associations' do
    it {should belong_to :customer}
    it {should have_many :transactions}
    it {should have_many :invoice_items}
    it {should have_many(:items).through(:invoice_items)}
  end

  describe 'validations' do
    it { should validate_presence_of :status }
    it { should define_enum_for(:status).with_values([:cancelled, 'in progress', :completed]) }
  end

  describe 'instance methods' do
    before(:each) do
      @merchant_1 = Merchant.create!(name: 'Korbanth')
      @discount_1 = @merchant_1.discounts.create!(quantity_threshold: 5, percentage_discount: 0.25, status: 0)

      @merchant_2 = Merchant.create!(name: 'Borkanth')
      @discount_2 = @merchant_2.discounts.create!(quantity_threshold: 1, percentage_discount: 0.10, status: 0)
      @discount_3 = @merchant_2.discounts.create!(quantity_threshold: 2, percentage_discount: 0.25, status: 0)
      @discount_4 = @merchant_2.discounts.create!(quantity_threshold: 5, percentage_discount: 0.33, status: 0)

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

      @invoice_1 = @customer_1.invoices.create!(status: 1)
      @invoice_2 = @customer_1.invoices.create!(status: 1)

      @invoice_item_1 = InvoiceItem.create!(
        item: @item_1,
        invoice: @invoice_1,
        quantity: 1,
        unit_price: 25_000,
        status: 0)
      @invoice_item_2 = InvoiceItem.create!(
        item: @item_2,
        invoice: @invoice_1,
        quantity: 1,
        unit_price: 1_500,
        status: 1)
      @invoice_item_3 = InvoiceItem.create!(
        item: @item_3,
        invoice: @invoice_1,
        quantity: 6,
        unit_price: 60_000,
        status: 1)
      @invoice_item_4 = InvoiceItem.create!(
        item: @item_3,
        invoice: @invoice_2,
        quantity: 1,
        unit_price: 60_000,
        status: 1)
      @invoice_item_5 = InvoiceItem.create!(
        item: @item_4,
        invoice: @invoice_2,
        quantity: 2,
        unit_price: 10_000,
        status: 1)
    end

    describe '#invoice_revenue' do
      it 'calculates the total revenue potential of the invoice' do
        expect(@invoice_1.invoice_revenue).to eq(386_500)
      end
    end

    describe '#invoice_item_quantities' do
      it 'calculates the total quantity ordered and revenue potential for each item on the invoice' do
        expected = @invoice_1.invoice_item_totals
        expected_with_optional_arg = @invoice_1.invoice_item_totals(@merchant_1.id)
        expect(expected).to eq(expected_with_optional_arg)

        expect(@invoice_2.invoice_item_totals).to_not eq(@invoice_2.invoice_item_totals(@merchant_2.id))

        expect(expected.length).to eq(3)
        expect(expected[0].id).to eq(@invoice_item_1.id)
        expect(expected[1].id).to eq(@invoice_item_2.id)
        expect(expected[2].id).to eq(@invoice_item_3.id)

        expect(expected[0].quantity).to eq(@invoice_item_1.quantity)
        expect(expected[1].quantity).to eq(@invoice_item_2.quantity)
        expect(expected[2].quantity).to eq(@invoice_item_3.quantity)

        expect(expected[0].revenue_potential).to eq(@invoice_item_1.quantity * @invoice_item_1.unit_price)
        expect(expected[1].revenue_potential).to eq(@invoice_item_2.quantity * @invoice_item_2.unit_price)
        expect(expected[2].revenue_potential).to eq(@invoice_item_3.quantity * @invoice_item_3.unit_price)
      end
    end

    describe '#discounted_revenue_for_merchant' do
      it 'calculates the total discounted revenue for the merchant invoice' do
        merchant_1_expected = @invoice_1.discounted_revenue_for_merchant(@merchant_1)
        expect(merchant_1_expected).to eq(296_500)

        merchant_2_expected = @invoice_2.discounted_revenue_for_merchant(@merchant_2)
        expect(merchant_2_expected).to eq(15_000)
      end
    end
  end

end
