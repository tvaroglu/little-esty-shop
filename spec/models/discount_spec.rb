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
      @merchant_1 = Merchant.create!(name: 'Tom Holland', status: 0)
      @discount_1 = @merchant_1.discounts.create!(quantity_threshold: 1, percentage_discount: 0.25, status: 0)
      @discount_2 = @merchant_1.discounts.create!(quantity_threshold: 5, percentage_discount: 0.5, status: 0)

      @merchant_2 = Merchant.create!(name: 'Borkanth')

      @customer_1 = Customer.create!(first_name: 'Green', last_name: 'Goblin')

      @invoice_1 = Invoice.create!(status: 2, customer_id: @customer_1.id)

      @item_1 = Item.create!(name: 'spider suit', description: 'saves lives', unit_price: '10000', merchant_id: @merchant_1.id)
      @item_2 = Item.create!(name: 'web shooter', description: 'shoots webs', unit_price: '5000', merchant_id: @merchant_1.id)
      @item_3 = Item.create!(name: 'upside down kiss', description: 'That Mary jane Swag', unit_price: '15000', merchant_id: @merchant_1.id)

      @inv_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 200, status: 1)
    end

    describe '#status_opposite' do
      it "returns the opposite of the discount's enabled/disabled status" do
        expect(@discount_1.status).to eq('enabled')
        expect(@discount_1.status_opposite).to eq('disabled')
      end
    end

    describe '#formatted_percentage' do
      it "returns the formatted percentage of the discount's percentage discount table column" do
        expect(@discount_1.formatted_percentage).to eq("#{(@discount_1.percentage_discount * 100).round}%")
      end
    end

    describe '#has_multiple_discounts?' do
      it "returns a boolean to signify whether a merchant has multiple discounts" do
        expect(@merchant_1.has_multiple_discounts?).to be true
        expect(@merchant_2.has_multiple_discounts?).to be false
      end
    end

    describe '#discounts_ordered_by_percentage_discount' do
      it "returns all discounts in descending order of percentage_discount when a merchant has multiple discounts" do
        expect(@merchant_1.discounts_ordered_by_percentage_discount).to eq([@discount_2, @discount_1])
      end
    end

    describe '#best_discount' do
      it "returns the best discount for a merchant based on the percentage_discount column" do
        expect(@merchant_1.best_discount).to eq(@discount_2)
        expect(@merchant_2.best_discount).to eq(nil)
      end
    end
  end

end
