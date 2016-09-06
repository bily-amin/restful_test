class UsersController < ApplicationController
  before_filter :basic_authenticate!
  respond_to :json

  def index
    @users = User.scoped
    #filter result
    @users = User.where(params[:filter_field] => params[:filter_value]) if params[:filter_field].present? and params[:filter_value].present?
    #order result
    @users.order(params[:sort_field]+' '+params[:sort_order_mode]) if params[:sort_order_mode].present? and params[:sort_field] and order_modes.include? params[:sort_order_mode].downcase
    #paginate result: page default is 1, page_size default is 25
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(params[:page_size])
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def create
    #remove unnecessary params
    exclude_items_from params
    @user = User.new(params)
    if @user.save
      respond_with @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    exclude_items_from params
    @user.update_attributes(params)
    if
      render json: @user, status: 200
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render nothing: true, status: 200
  end
  private
  def order_modes
    %w(asc desc)
  end
  def exclude_items_from(params)
    %w(format controller action user).each do |key|
      params.delete(key)
    end
  end
  def basic_authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      username == "test" && password == "pass1234"
    end
  end
end
