require 'rails_helper'
require 'net/http'
require 'json'

describe CarRecommendationFetcherService do
  describe '#run!' do
    let!(:user) { create(:user) }
    let(:car_a) { create(:car) }
    let(:car_b) { create(:car) }
    let(:base_url) { 'https://bravado-images-production.s3.amazonaws.com/recomended_cars.json' }
    let(:url) { "#{base_url}?user_id=#{user.id}" }
    let(:response_body) do
      [
        { 'car_id' => car_a.id, 'rank_score' => 4.5 },
        { 'car_id' => car_b.id, 'rank_score' => 3.8 }
      ].to_json
    end

    before do
      allow(Net::HTTP).to receive(:get).with(URI(url)).and_return(response_body)
    end

    context 'when UserCarRank does not exist' do
      it 'creates a new UserCarRank record for each recommendation' do
        expect {
          described_class.new.run!(user.id)
        }.to change { UserCarRank.count }.by(2)

        first_rank = UserCarRank.find_by(user_id: user.id, car_id: car_a.id)
        second_rank = UserCarRank.find_by(user_id: user.id, car_id: car_b.id)

        expect(first_rank).to have_attributes(rank_score: 4.5)
        expect(second_rank).to have_attributes(rank_score: 3.8)
      end
    end

    context 'when UserCarRank exists' do
      before do
        UserCarRank.create!(user_id: user.id, car_id: car_a.id, rank_score: 3.0)
      end

      it 'updates the existing UserCarRank record with the new rank_score' do
        expect {
          described_class.new.run!(user.id)
        }.to change { UserCarRank.count }.by(1)

        updated_rank = UserCarRank.find_by(user_id: user.id, car_id: car_a.id)
        expect(updated_rank.rank_score).to eq(4.5)
      end

      it 'creates new records for recommendations not in the database' do
        expect {
          described_class.new.run!(user.id)
        }.to change { UserCarRank.count }.by(1)

        new_rank = UserCarRank.find_by(user_id: user.id, car_id: car_b.id)
        expect(new_rank.rank_score).to eq(3.8)
      end
    end
  end
end
