class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_suggestions, if: :user_signed_in?

  def index
    if user_signed_in?
      @posts = Post.where(user: current_user.following + [current_user])
                   .order(created_at: :desc)
                   .includes(:user, :likes, :comments)
                   .page(params[:page]).per(10)
    else
      @posts = Post.all.order(created_at: :desc)
                   .includes(:user, :likes, :comments)
                   .page(params[:page]).per(10)
    end
  end

  private

  def set_suggestions
    @suggestions = [current_user.followers]
    [current_user.followers, current_user.followings].flatten.uniq.each do |f|
      @suggestions.append([f.followers, f.followings])
    end
    @suggestions = [@suggestions, User.all.sample(10)].flatten.uniq - [current_user.followings, current_user].flatten.uniq
    @suggestions = @suggestions.sample(5)
  end
end
