class Invoice < ApplicationRecord
  enum status: { cancelled: 0, 'in progress' => 1, completed: 2 }
  validates :status, presence: true, inclusion: { in: Invoice.statuses.keys }

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items


  def invoice_revenue
    invoice_items.sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def invoice_item_totals_ordered_by_quantity(merchant_id = nil)
    query = invoice_items.select("invoice_items.id, invoice_items.quantity,
      SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue_potential")
    .joins(item: :merchant)
    .group("invoice_items.id")
    .order("invoice_items.quantity DESC")
    merchant_id.nil? ? query : query.where("items.merchant_id = ?", merchant_id)
  end

  def applicable_discount_for_merchant(merchant, invoice_item)
    discount = merchant.discounts_ordered_by_percentage_discount
    .where("quantity_threshold <= ?", invoice_item.quantity)
    .first
    !discount.nil? ? discount : merchant.discounts_ordered_by_percentage_discount.first
  end

  def discounted_revenue_for_merchant(merchant)
    invoice_item_totals_ordered_by_quantity(merchant.id).reduce(0) do |total, invoice_item|
      if invoice_item.quantity >= applicable_discount_for_merchant(merchant, invoice_item).quantity_threshold
        total + (invoice_item.revenue_potential * (1 - applicable_discount_for_merchant(merchant, invoice_item).percentage_discount))
      else
        total + invoice_item.revenue_potential
      end
    end
  end

end
