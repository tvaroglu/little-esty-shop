class Discount < ApplicationRecord
  enum status: {enabled: 0, disabled: 1}
  validates :status, presence: true, inclusion: { in: Discount.statuses.keys }

  validates :quantity_threshold, presence: true, numericality: { only_integer: true }
  validates :percentage_discount, presence: true

  belongs_to :merchant


  def status_opposite
    status == 'enabled' ? 'disabled' : 'enabled'
  end

end
