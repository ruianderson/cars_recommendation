class CarsController < ApplicationController
  def search
    result = CarsFinderService.new(permitted_params).result
    render json: result
  end

  private

  def permitted_params
    params.permit(:user_id, :query, :price_min, :price_max, :page)
  end
end
