require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let!(:user) { create(:user, name: 'Гарри') }

  context "user view's his own profile" do
    before do
      sign_in user
      assign(:games, [stub_template('users/_game.html.erb' => 'User game goes here')])
      assign(:user, user)

      render
    end

    it 'renders player name' do
      expect(rendered).to match 'Гарри'
    end

    it 'renders password changing link' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders games partial' do
      expect(rendered).to have_content 'User game goes here'
    end
  end

  context "user views other user's profile" do
    before do
      assign(:user, user)

      render
    end

    it 'does not render password changing link' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end