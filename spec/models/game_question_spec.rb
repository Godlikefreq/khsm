require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe '#variants' do
    it 'returns correct variants' do
      expect(game_question.variants).to eq({ 'a' => game_question.question.answer2,
                                             'b' => game_question.question.answer1,
                                             'c' => game_question.question.answer4,
                                             'd' => game_question.question.answer3 })
    end
  end

  describe '#answer_correct?' do
    it 'matches correct answer' do
      expect(game_question.answer_correct?('b')).to be true
    end
  end

  describe '#level & #text delegates' do
    it 'matches current text' do
      expect(game_question.text).to eq(game_question.question.text)
    end

    it 'matches current level' do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe '#correct_answer_key' do
    it 'returns correct answer key' do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe '#add_audience_help' do
    before { game_question.add_audience_help }
    let!(:ah) { game_question.help_hash[:audience_help] }

    it 'help_hash includes audience_help' do
      expect(game_question.help_hash).to include(:audience_help)
    end

    it 'contains all keys' do
      expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
    end
  end

  describe '#add_fifty_fifty' do
    before { game_question.add_fifty_fifty }
    let!(:ff) { game_question.help_hash[:fifty_fifty] }

    it 'help_hash includes fifty_fifty' do
      expect(game_question.help_hash).to include(:fifty_fifty)
    end

    it 'contains correct key' do
      expect(ff).to include(game_question.correct_answer_key)
    end

    it 'has a size 2' do
      expect(ff.size).to eq 2
    end
  end

  describe '#add_friend_call' do
    before { game_question.add_friend_call }
    let!(:fc) { game_question.help_hash[:friend_call] }

    it 'help_hash includes fifty_fifty' do
      expect(game_question.help_hash).to include(:friend_call)
    end

    it 'contains answer key' do
      expect(fc).to include('A').or(include('B')).or(include('C')).or(include('D'))
    end

    it 'is a string' do
      expect(fc).to be_an(String)
    end
  end
end
