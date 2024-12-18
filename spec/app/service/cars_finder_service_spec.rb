require 'rails_helper'

RSpec.describe CarsFinderService do
  let(:toyota) { create(:brand, name: 'Toyota') }
  let!(:corolla) do
    create(:car, model: 'Corolla', price: 37_000, brand: toyota)
  end

  let(:honda) { create(:brand, name: 'Honda') }
  let!(:civic) do
    create(:car, model: 'Civic', price: 30_000, brand: honda)
  end
  let!(:accord) do
    create(:car, model: 'Accord', price: 41_000, brand: honda)
  end

  let(:volkswagen) { create(:brand, name: 'Volkswagen') }
  let!(:golf) do
    create(:car, model: 'Golf', brand: volkswagen, price: 36_000)
  end

  let(:user) do 
    create(:user, preferred_price_range: 35_000...40_000).tap do |_user|
      _user.preferred_brands << toyota
      _user.preferred_brands << honda
      _user
    end
  end

  let!(:user_b) do 
    create(:user).tap do |_user|
      _user.preferred_brands << volkswagen
      _user
    end
  end

  let(:params) do
    {
      user_id: user.id
    }
  end

  subject { described_class.new(params) }

  describe '#result' do
    it 'returns cars' do
      result = subject.result.map do |entry|
        { model: entry.model, brand: entry.brand.name, label: entry.label }
      end

      expect(result).to match_array([
        { model: 'Corolla', brand: 'Toyota', label: 'perfect_match' },
        { model: 'Civic', brand: 'Honda', label: 'good_match' },
        { model: 'Accord', brand: 'Honda', label: 'good_match' },
        { model: 'Golf', brand: 'Volkswagen', label: nil }
      ])
    end

    context 'when query parameter is present' do
      let(:params) do
        {
          user_id: user.id,
          query: 'yota'
        }
      end

      it 'filters the result by matching brand name' do
        result = subject.result.map do |entry|
          { model: entry.model, brand: entry.brand.name }
        end

        expect(result).to match_array([
          { model: 'Corolla', brand: 'Toyota' },
        ])
      end
    end

    context 'when price min is present' do
      let(:params) do
        {
          user_id: user.id,
          price_min: 35_000,
        }
      end

      it 'filters the result by matching cars with minimum price' do
        result = subject.result.map do |entry|
          { model: entry.model, brand: entry.brand.name }
        end

        expect(result).to match_array([
          { model: 'Corolla', brand: 'Toyota' },
          { model: 'Accord', brand: 'Honda' },
          { model: 'Golf', brand: 'Volkswagen' }
        ])
      end
    end

    context 'when price max is present' do
      let(:params) do
        {
          user_id: user.id,
          price_max: 35_000,
        }
      end

      it 'filters the result by matching cars with minimum price' do
        result = subject.result.map do |entry|
          { model: entry.model, brand: entry.brand.name }
        end

        expect(result).to match_array([
          { model: 'Civic', brand: 'Honda' },
        ])
      end
    end

    context 'sorting' do
      it 'sorts first by label' do
        result = subject.result.map do |entry|
          { model: entry.model, brand: entry.brand.name, label: entry.label }
        end

        expect(result).to eq([
          { model: 'Corolla', brand: 'Toyota', label: 'perfect_match' },
          { model: 'Civic', brand: 'Honda', label: 'good_match' },
          { model: 'Accord', brand: 'Honda', label: 'good_match' },
          { model: 'Golf', brand: 'Volkswagen', label: nil }
        ])
      end

      context 'pricing' do
        before do
          civic.update(price: 22_000)
          accord.update(price: 21_000)
        end

        it 'sorts first by price' do
          result = subject.result.map do |entry|
            { model: entry.model, brand: entry.brand.name, label: entry.label }
          end

          expect(result).to eq([
            { model: 'Corolla', brand: 'Toyota', label: 'perfect_match' },
            { model: 'Accord', brand: 'Honda', label: 'good_match' },
            { model: 'Civic', brand: 'Honda', label: 'good_match' },
            { model: 'Golf', brand: 'Volkswagen', label: nil }
          ])
        end
      end

      context 'when rank score is available' do
        before do
          create(:user_car_rank, car: civic, user: user, rank_score: 0.8)
          create(:user_car_rank, car: accord, user: user, rank_score: 1.0)
          create(:user_car_rank, car: golf, user: user, rank_score: 0.9)
        end

        it 'sorts by rank score' do
          result = subject.result.map do |entry|
            {
              model: entry.model,
              brand: entry.brand.name,
              label: entry.label,
              rank_score: entry.rank_score
            }
          end

          expect(result).to eq([
            { model: 'Corolla', brand: 'Toyota', label: 'perfect_match', rank_score: nil },
            { model: 'Accord', brand: 'Honda', label: 'good_match', rank_score: 1.0 },
            { model: 'Civic', brand: 'Honda', label: 'good_match', rank_score: 0.8 },
            { model: 'Golf', brand: 'Volkswagen', label: nil, rank_score: 0.9 }
          ])
        end
      end
    end
  end
end
