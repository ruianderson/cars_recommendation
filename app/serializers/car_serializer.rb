class CarSerializer < ActiveModel::Serializer
  attributes :id, :model, :price, :label, :rank_score
  belongs_to :brand, serializer: BrandSerializer
end
