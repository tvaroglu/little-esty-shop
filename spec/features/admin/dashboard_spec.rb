require 'rails_helper'

RSpec.describe 'Admin Dashboard page' do
  before do
    visit '/admin'
  end

  it 'is on the right page' do
    expect(page).to have_current_path('/admin')
  end

  it 'displays the header' do
    expect(page).to have_content('Admin Dashboard')
  end

  it 'can take the user to the admin merchants page' do
    click_link 'Merchants Index'
    expect(page).to have_current_path('/admin/merchants'), ignore_query: true
  end

  it 'can take the user to the admin invoices page' do
    click_link 'Invoices Index'
    expect(page).to have_current_path('/admin/invoices'), ignore_query: true
  end
end
