require 'rails_helper'
RSpec.describe 'Test Features' do
    it 'Displays the name of the app' do
        visit('/test')
        expect(page).to have_content('Share Lettings and Sales for Social Housing in England Data with MHCLG')
    end

    it 'Links to the About page' do
        visit('/test')
        click_link('About')
        expect(current_path).to eql('/about')
        expect(page).to have_content('About')
    end
end 