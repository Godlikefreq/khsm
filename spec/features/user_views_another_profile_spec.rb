require 'rails_helper'

RSpec.feature 'USER views another profile', type: :feature do
  let(:user1) { FactoryBot.create :user, name: 'Вася', id: 1 }
  let(:user2) { FactoryBot.create :user }

  let!(:game1) { FactoryBot.create :game_with_questions, user: user1, id: 1,
                                   current_level: 3,
                                   prize: 0,
                                   is_failed: true,
                                   created_at: '2023-01-25 21:15:13 +0300'.to_datetime,
                                   finished_at: '2023-01-25 21:19:13 +0300'.to_datetime }
  let!(:game2) { FactoryBot.create :game_with_questions, user: user1, id: 2,
                                   current_level: 15,
                                   prize: 1000000,
                                   created_at: '2023-01-26 22:03:13 +0300'.to_datetime,
                                   finished_at: '2023-01-26 22:23:13 +0300'.to_datetime }

  before { login_as user2 }

  scenario 'successfully' do
    visit '/users/1'

    expect(page).to have_content 'Вася'

    expect(page).to have_no_link 'Сменить имя и пароль'

    expect(page).to have_content '1'
    expect(page).to have_content 'проигрыш'
    expect(page).to have_content '25 янв., 21:15'
    expect(page).to have_content '3'
    expect(page).to have_content '0'

    expect(page).to have_content '2'
    expect(page).to have_content 'победа'
    expect(page).to have_content '26 янв., 22:03'
    expect(page).to have_content '15'
    expect(page).to have_content '1 000 000'
  end
end