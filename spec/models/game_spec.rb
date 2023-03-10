# (c) goodprogrammer.ru

require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для модели Игры
# В идеале - все методы должны быть покрыты тестами,
# в этом классе содержится ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  let(:q) { game_w_questions.current_game_question }

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # генерим 60 вопросов с 4х запасом по полю level,
      # чтобы проверить работу RANDOM при создании игры
      generate_questions(60)

      game = nil
      # создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(# проверка: Game.count изменился на 1 (создали в базе 1 игру)
        change(GameQuestion, :count).by(15).and(# GameQuestion.count +15
          change(Question, :count).by(0) # Game.count не должен измениться
        )
      )
      # проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      # проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # тесты на основную игровую логику
  context 'game mechanics' do

    # правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # текущий уровень игры и статус
      level = game_w_questions.current_level
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)
      # ранее текущий вопрос стал предыдущим
      expect(game_w_questions.previous_game_question).to eq(q)
      expect(game_w_questions.current_game_question).not_to eq(q)
      # игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    describe '#take_money!' do
      it 'it finishes game' do
        game_w_questions.answer_current_question!(q.correct_answer_key)

        game_w_questions.take_money!

        prize = game_w_questions.prize
        expect(prize).to be > 0

        expect(game_w_questions.status).to eq :money
        expect(game_w_questions.finished?).to be_truthy
        expect(user.balance).to eq prize
      end
    end

    describe '#current_game_question' do
      it 'returns current question' do
        expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
      end
    end

    describe '#previous_level' do
      before do
        game_w_questions.answer_current_question!(q.correct_answer_key)
      end

      it 'matches previous level' do
        expect(game_w_questions.previous_level).to be(0)
      end
    end

    describe '#answer_current_question!' do
      before { game_w_questions.answer_current_question!(answer_key) }

      context 'when answer is correct' do
        let!(:answer_key) { q.correct_answer_key }
        let!(:level) { Question::QUESTION_LEVELS.first }

        it 'raises current level' do
          expect(game_w_questions.current_level).to be(1)
        end

        it 'continues the game' do
          expect(game_w_questions.status).to eq(:in_progress)
        end

        it 'game is not finished' do
          expect(game_w_questions.finished?).to be false
        end

        context 'and question is last' do
          let!(:level) { Question::QUESTION_LEVELS.last }
          let!(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, current_level: level) }

          it 'max prize pool' do
            expect(game_w_questions.prize).to eq(1000000)
          end

          it 'finished game' do
            expect(game_w_questions.finished?).to be true
          end

          it 'finished with status "won"' do
            expect(game_w_questions.status).to eq(:won)
          end
        end

        context 'and time is over' do
          let!(:level) { Question::QUESTION_LEVELS.first(11).last }
          let!(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, created_at: 1.hour.ago, current_level: level) }

          it 'ends game' do
            expect(game_w_questions.finished?).to be true
          end

          it 'saves last fire proof prize pool' do
            expect(game_w_questions.prize).to eq(32000)
          end

          it 'finished game with status "timeout"' do
            expect(game_w_questions.status).to eq(:timeout)
          end
        end
      end

      context 'given wrong answer' do
        let!(:answer_key) { %w[a b c d].grep_v(q.correct_answer_key).sample }

        it 'finished game' do
          expect(game_w_questions.finished?).to be true
        end

        it 'finished with previous prize pool' do
          expect(game_w_questions.prize).to be(0)
        end

        it 'finished with fail status' do
          expect(game_w_questions.status).to eq(:fail)
        end
      end
    end
  end

  context 'game status' do
    describe '.status' do
      before do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be_truthy
      end

      it ':won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it ':fail' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it ':timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it ':money' do
        expect(game_w_questions.status).to eq(:money)
      end
    end
  end
end