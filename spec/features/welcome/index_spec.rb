require 'rails_helper'

RSpec.describe 'Welcome Page' do
  before do
    visit '/'
  end

  it 'is on the correct paage' do
    expect(page).to have_current_path('/')
  end

  it 'can take user to merchants index page' do
    first(:link, 'Merchants').click

    expect(page).to have_current_path('/merchants')
  end

  it 'can take the user to the admin dashboard page' do
    within('ul#dropdownmenu-admin') do
      click_on 'Dashboard'
      expect(page).to have_current_path('/admin')
    end
  end

  it 'can take the user to the admin merchants index page' do
    within('ul#dropdownmenu-admin') do
      click_on 'Merchants'
      expect(page).to have_current_path('/admin/merchants')
    end
  end

  it 'can take the user to the admin invoices index page' do
    within('ul#dropdownmenu-admin') do
      click_on 'Invoices'
      expect(page).to have_current_path('/admin/invoices')
    end
  end

  it 'can take user to admin feeling lucky index page' do
    click_link 'Feeling Lucky 😎'

    expect(page).to have_current_path('/')
  end
end
