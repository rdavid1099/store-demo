class ProductsController < ApplicationController
  def index
    @products = Search.filter_products(params)
    @categories = Category.all
  end

  def show
    session[:return_to] = request.fullpath
    @product = Product.find(params[:id])
    @ratings = Rating.fetch_all_for({product: @product.id})
  end
end
