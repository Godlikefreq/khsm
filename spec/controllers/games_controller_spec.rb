require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }
  let(:game) { assigns(:game) }

  describe '#show' do
    context 'when anon' do
      before { get :show, params: { id: game_w_questions.id } }

      it 'returns bad response' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to registration' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'renders flash alert message' do
        expect(flash[:alert]).to be
      end
    end

    context 'when signed_in' do
      before { sign_in user }

      context 'and viewing user\'s own game' do
        before { get :show, params: { id: game_w_questions.id } }

        it 'game is not finished' do
          expect(game.finished?).to be false
        end

        it 'assigns user to game' do
          expect(game.user).to eq(user)
        end

        it 'respond with good status' do
          expect(response.status).to eq(200)
        end

        it 'renders show' do
          expect(response).to render_template('show')
        end
      end

      context 'and viewing another user\'s game' do
        let!(:game_w_questions) { FactoryBot.create(:game_with_questions) }
        before { get :show, params: { id: game_w_questions.id } }

        it 'returns bad response' do
          expect(response.status).not_to eq(200)
        end

        it 'redirects to home page' do
          expect(response).to redirect_to(root_path)
        end

        it 'renders flash message' do
          expect(flash[:alert]).to be
        end
      end
    end
  end

  describe '#create' do
    context 'when anon' do
      before { post :create }

      it 'returns bad response' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to registration' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'renders flash alert message' do
        expect(flash[:alert]).to be
      end
    end

    context 'when signed_in' do
      before { sign_in user }

      context 'and creating first game' do
        before { generate_questions(15) }
        before { post :create }

        it 'game is not finished' do
          expect(game.finished?).to be false
        end

        it 'assigns user to game' do
          expect(game.user).to eq(user)
        end

        it 'redirects to game path' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'renders flash notice' do
          expect(flash[:notice]).to be
        end
      end

      context 'and creating second game with first game not finished' do
        let!(:existing_game) { game_w_questions }
        before { post :create }

        it 'first game is in progress' do
          expect(existing_game.status).to eq(:in_progress)
        end

        it 'doesn\'t create new game' do
          expect { post :create }.to change(Game, :count).by(0)
        end

        it 'doesn\'t assing game to variable' do
          expect(game).to be nil
        end

        it 'redirects to game that already in progress' do
          expect(response).to redirect_to(game_path(existing_game))
        end

        it 'renders flash alert' do
          expect(flash[:alert]).to be
        end
      end
    end
  end

  describe '#answer' do
    context 'when anon' do
      before { put :answer, params: { id: game_w_questions.id } }

      it 'returns bad response' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to registration' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'renders flash alert message' do
        expect(flash[:alert]).to be
      end
    end

    context 'when signed_in' do
      before { sign_in user }

      context 'and answer is correct' do
        before { put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key } }

        it 'game is not finished' do
          expect(game.finished?).to be false
        end

        it 'raises level from 0 to 1' do
          expect(game.current_level).to be > 0
        end

        it 'redirects to game path' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'renders flash success message' do
          expect(flash[:success]).to be
        end
      end

      context 'and answer is wrong' do
        before { put :answer, params: { id: game_w_questions.id,
                                        letter: %w[a b c d].grep_v(game_w_questions.current_game_question.correct_answer_key).sample } }

        it 'finished game' do
          expect(game.finished?).to be true
        end

        it 'game has fail status' do
          expect(game.status).to eq(:fail)
        end

        it 'redirects to user path' do
          expect(response).to redirect_to(user_path(user))
        end

        it 'renders flash success message' do
          expect(flash[:success]).to be
        end
      end
    end
  end

  describe '#take_money' do
    context 'when anon' do
      before { put :take_money, params: { id: game_w_questions.id } }

      it 'returns bad response' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to registration' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'renders flash alert message' do
        expect(flash[:alert]).to be
      end
    end

    context 'when signed_in' do
      before { sign_in user }
      let!(:level) { Question::QUESTION_LEVELS.first(3).last }
      let!(:game_w_questions) { FactoryBot.create(:game_with_questions, current_level: level, user: user) }
      before { put :take_money, params: { id: game_w_questions.id } }

      it 'finished game' do
        expect(game.finished?).to be true
      end

      it 'assigns current prize' do
        expect(game.prize).to eq(200)
      end

      it 'updates user balance' do
        user.reload
        expect(user.balance).to eq(200)
      end

      it 'redirects to user_path' do
        expect(response).to redirect_to(user_path(user))
      end

      it 'renders flash message' do
        expect(flash[:success]).to be
      end
    end
  end

  describe '#help' do
    context 'when anon' do
      before { put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty } }

      it 'returns bad response' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to registration' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'renders flash alert message' do
        expect(flash[:alert]).to be
      end
    end

    context 'when signed_in' do
      before { sign_in user }

      context 'and used audience_help' do
        before { put :help, params: { id: game_w_questions.id, help_type: :audience_help } }

        it 'does not finished game' do
          expect(game.finished?).to be false
        end

        it 'added flag "used" to used hint' do
          expect(game.audience_help_used).to be true
        end

        it 'shown audience help hash' do
          expect(game.current_game_question.help_hash[:audience_help]).to be
        end

        it 'contains correct keys' do
          expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
        end

        it 'redirects to game path' do
          expect(response).to redirect_to(game_path(game))
        end
      end

      context 'and used fifty_fifty' do
        before { put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty } }

        it 'does not finished game' do
          expect(game.finished?).to be false
        end

        it 'added flag "used" to used hint' do
          expect(game.fifty_fifty_used).to be true
        end

        it 'shown audience help hash' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to be
        end

        it 'contains answer key' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game_w_questions.current_game_question.correct_answer_key)
        end

        it 'has a size 2' do
          expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq 2
        end

        it 'is an array' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to be_an(Array)
        end

        it 'redirects to game path' do
          expect(response).to redirect_to(game_path(game))
        end
      end
    end
  end
end
