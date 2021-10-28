require 'rails_helper'

RSpec.describe 'Admin Invoice Edit Page' do
  before do
    @customer = Customer.create(first_name: 'Tom', last_name: 'Holland')
    @i = Invoice.create!(status: 2, customer_id: @customer.id)

    visit "/admin/invoices/#{@i.id}/edit"
  end

  it 'is on the correct page' do
    expect(page).to have_current_path("/admin/invoices/#{@i.id}/edit", ignore_query: true)
    expect(page).to have_content('Editing Admin Invoice')
  end
end
