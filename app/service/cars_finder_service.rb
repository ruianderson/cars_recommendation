class CarsFinderService
  def initialize(params)
    @user_id = params.fetch(:user_id)
    @query = params[:query]
    @price_min = params[:price_min]
    @price_max = params[:price_max]
    @page = [params[:page].to_i, 1].max
  end

  def result
    scope = Car.joins(:brand).joins(
     "LEFT JOIN user_car_ranks ON user_car_ranks.car_id = cars.id AND user_car_ranks.user_id = #{user_id}"
    )

    scope = scope.where("brands.name ILIKE ?", "%#{query}%") if query.present?
    scope = scope.where("price >= ?", price_min) if price_min.present?
    scope = scope.where("price <= ?", price_max) if price_max.present?

    # Add label & rank_score fields
    scope = scope.select(
      'cars.*',
      'user_car_ranks.rank_score',
      label_case_sql
    )

    # Sort
    scope = scope.order(order_sql)

    scope.limit(10).offset((page - 1) * 10)
  end

  private

  attr_reader :page, :price_min, :price_max, :query, :user_id

  def user
    @user ||= User.find(user_id)
  end

  def label_case_sql
    preferred_brand_ids = user.preferred_brands.pluck(:id)
    preferred_price_range = user.preferred_price_range

    brand_condition = preferred_brand_ids.any? ? "cars.brand_id IN (#{preferred_brand_ids.join(',')})" : "FALSE"
    price_condition = preferred_price_range.present? ? "cars.price BETWEEN #{preferred_price_range.min} AND #{preferred_price_range.max}" : "FALSE"

    <<~SQL
      CASE
        WHEN #{brand_condition} AND #{price_condition}
        THEN 'perfect_match'
        WHEN #{brand_condition}
        THEN 'good_match'
        ELSE null
      END AS label
    SQL
  end

  def order_sql
    preferred_brand_ids = user.preferred_brands.pluck(:id)
    preferred_price_range = user.preferred_price_range

    brand_condition = preferred_brand_ids.any? ? "cars.brand_id IN (#{preferred_brand_ids.join(',')})" : "FALSE"
    price_condition = preferred_price_range.present? ? "cars.price BETWEEN #{preferred_price_range.min} AND #{preferred_price_range.max}" : "FALSE"

     Arel.sql(<<~SQL)
      CASE
        WHEN #{brand_condition} AND #{price_condition}
        THEN 1
        WHEN #{brand_condition}
        THEN 2
        ELSE 3
      END ASC,
      user_car_ranks.rank_score DESC NULLS LAST,
      cars.price ASC
    SQL
  end
end
