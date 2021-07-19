require 'rails_helper'
RSpec.describe 'Test Features' do
    it 'Displays the name of the app' do
        visit('/test')
        expect(page).to have_content('Share Lettings and Sales for Social Housing in England Data with MHCLG')
    end
end 