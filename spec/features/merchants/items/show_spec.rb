require 'rails_helper'

RSpec.describe "The Merchant Item show page" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Korbanth')
    @item1 = @merchant1.items.create!(
      name: 'SK2',
      description: "Starkiller's lightsaber from TFU2 promo trailer",
      unit_price: 25_000
    )
    @item2 = @merchant1.items.create!(
      name: 'Shtok eco',
      description: "Hilt side lit pcb",
      unit_price: 1_500
    )
  end

  it "displays all of the item's attributes including: Name, Description, Current Selling Price" do
    visit merchant_item_path(@merchant1.id, @item1.id)

    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@item1.description)
    expect(page).to have_content('$250.00')
    expect(page).to_not have_content(@item2.name)
    expect(page).to_not have_content(@item2.description)
    expect(page).to_not have_content(@item2.unit_price)
  end

  it "displays a link to return to the items' index page" do
    visit merchant_item_path(@merchant1.id, @item1.id)

    expect(page).to have_link('Return to Items Index')
    click_on 'Return to Items Index'
    expect(current_path).to eq(merchant_items_path(@merchant1.id))
  end

  describe 'Merchant Item update link' do
    # As a merchant,
      # When I visit the merchant show page of an item
      # I see a link to update the item information.
    it 'displays a link to update the item information; when clicked, taken to page to edit the item' do
      visit merchant_item_path(@merchant1.id, @item1.id)

      click_link 'Update Item Information'
      expect(current_path).to eq(edit_merchant_item_path(@merchant1.id, @item1.id))
    end
  end
end
