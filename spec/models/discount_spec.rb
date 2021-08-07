require 'rails_helper'

RSpec.describe Discount do
  describe 'associations' do
    it {should belong_to :merchant}
  end

  describe 'validations' do
    it { should validate_presence_of :status }
    it { should define_enum_for(:status).with_values([:enabled, :disabled]) }

    it { should validate_presence_of :quantity_threshold }
    it { should validate_numericality_of(:quantity_threshold).only_integer }

    it { should validate_presence_of :percentage_discount }
  end

  describe 'methods' do
    before :each do
      @merchant = Merchant.create!(name: 'Tom Holland', status: 0)
      @discount = @merchant.discounts.create!(quantity_threshold: 5, percentage_discount: 0.5, status: 0)

      @customer_1 = Customer.create!(first_name: 'Green', last_name: 'Goblin')

      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id)

      @item_1 = Item.create!(name: 'spider suit', description: 'saves lives', unit_price: '10000', merchant_id: @merchant.id)
      @item_2 = Item.create!(name: 'web shooter', description: 'shoots webs', unit_price: '5000', merchant_id: @merchant.id)
      @item_3 = Item.create!(name: 'upside down kiss', description: 'That Mary jane Swag', unit_price: '15000', merchant_id: @merchant.id)

      @inv_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 200, status: 1)
    end

    describe '#status_opposite' do
      it "returns the opposite of the discount's enabled/disabled status" do
        expect(@discount.status).to eq('enabled')
        expect(@discount.status_opposite).to eq('disabled')
      end
    end

    describe '#formatted_percentage' do
      it "returns the formatted percentage of the discount's percentage discount table column" do
        expect(@discount.formatted_percentage).to eq("#{(@discount.percentage_discount * 100).round}%")
      end
    end
  end

end
