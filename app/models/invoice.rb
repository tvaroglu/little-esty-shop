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

  def invoice_item_totals(merchant_id = nil)
    query = invoice_items.select("invoice_items.id, invoice_items.quantity,
      SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue_potential")
    .joins(item: :merchant)
    .group("invoice_items.id")
    merchant_id == nil ? query : query.where("items.merchant_id = ?", merchant_id)
  end

  def applicable_discount_for_merchant(merchant)
    invoice_item_totals(merchant.id).each do |invoice_item|
      merchant.discounts_ordered_by_percentage_discount.each do |discount|
        return discount if invoice_item.quantity >= discount.quantity_threshold
      end
    end
  end

  def best_discount_for_merchant(merchant)
    merchant.has_multiple_discounts? ? applicable_discount_for_merchant(merchant): merchant.best_discount
  end

  def discounted_revenue_for_merchant(merchant)
    best_discount = best_discount_for_merchant(merchant)
    invoice_item_totals(merchant.id).reduce(0) do |total, invoice_item|
      if invoice_item.quantity >= best_discount.quantity_threshold
        total + (invoice_item.revenue_potential * (1 - best_discount.percentage_discount))
      else
        total + invoice_item.revenue_potential
      end
    end.round(2)
  end

end
