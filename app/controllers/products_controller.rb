class ProductsController < ApplicationController
  # ログイン中のユーザしかできない
  before_action :authenticate_user!, only: [:new, :create, :edit, :upload, :destroy]

  # 変数に商品を格納する
  before_action :set_product, only: [:edit, :update, :show, :destroy]

  # 出品したユーザしかできない
  before_action :ensure_currect_user, only: [:edit, :update, :destroy]

  # 変数に親カテゴリを格納する
  before_action :set_parents, only: [:index, :new, :create, :edit, :update, :show]

  # 親カテゴリの配列を用意する
  before_action :set_categories, only: [:index, :new, :create, :edit, :update]

  # 子カテゴリと孫カテゴリの配列を用意する
  before_action :set_categories_edit, only: [:edit, :update]

  # ブランド一覧を用意する
  before_action :set_brands, only: [:index, :new, :create, :edit, :update]

  def index
    @q = Product.ransack(params[:q])
    @results = @q.result.includes([:images, :brand, :category]).order("created_at DESC").page(params[:page]).per(5)
  end

  def new
    @product = Product.new
    @product.images.new
  end

  def create
    @product = Product.new(product_params)
    
    if @product.save
      flash[:notice] = "商品を出品しました"
      redirect_to root_path
      return
    else
      # renderで戻された時画像入力フォームがなくなってしまう事象への対策
      @product.images.new
      flash[:alert] = "商品を出品できませんでした"
      render :new
      return
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      flash[:notice] = "商品を編集しました"
      redirect_to root_path
      return
    else
      flash[:alert] = "商品を編集できませんでした"
      render :edit
      return
    end
  end

  def show
  end

  def destroy
    if @product.destroy
      flash[:notice] = "商品を削除しました"
    else
      flash[:alert] = "商品を削除できませんでした"
    end

    redirect_to root_path
    return
  end

  # 親カテゴリーが選択された時に動くアクション
  def get_category_children
    # 選択された親カテゴリーに対応する子カテゴリーの配列を取得
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  # 子カテゴリーが選択された時に動くアクション
  def get_category_grandchildren
    #選択された子カテゴリーに対応する孫カテゴリーの配列を取得
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  def fuzzy_search
    @results = Product.includes(:images).search(params[:keyword]).order("created_at DESC").page(params[:page]).per(5)
  end

  private

  def product_params
    params.require(:product).permit(
      :seller_id,
      :name,
      :explain,
      :category_id,
      :brand_id,
      :condition_id,
      :costburden_id,
      :shippingorigin_id,
      :shippingperiod_id,
      :price,
      images_attributes: [:id, :src, :_destroy],
      brand_attributes: [:id, :name],
    )
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def ensure_currect_user
    if @product.seller_id != current_user.id
      flash[:alert] = "権限がありません"
      redirect_to root_path
    else
      # nop
    end
  end

  def set_parents
    @parents = Category.where(ancestry: nil)
  end

  def set_categories
    # セレクトボックスの初期値設定
    @category_parent_array = []
    # 親カテゴリー名を抽出し配列化
    @parents.each do |parent|
      @category_parent_array << parent.name
    end
  end

  def set_categories_edit
    # productが所属する子カテゴリーの一覧を配列で取得
    @category_child_array = @product.category.parent.parent.children

    # productが所属する孫カテゴリーの一覧を配列で取得
    @category_grandchild_array = @product.category.parent.children
  end

  def set_brands
    @brands = Brand.all
  end
end
