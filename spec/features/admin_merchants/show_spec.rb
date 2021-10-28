require 'rails_helper'

RSpec.describe 'Admin Merchants Show Page' do
  before do
    @merchant1 = Merchant.create!(name: 'Tom Holland')

    visit "/admin/merchants/#{@merchant1.id}"
  end

  it 'is on the correct page' do
    expect(page).to have_current_path("/admin/merchants/#{@merchant1.id}", ignore_query: true)
    expect(page).to have_content(@merchant1.name.to_s)
  end

  it 'can take user to edit merchant edit page' do
    click_on 'Edit'

    expect(page).to have_current_path("/admin/merchants/#{@merchant1.id}/edit", ignore_query: true)
    expect(page).to have_content("Editing Merchant: #{@merchant1.name}")
  end
end
