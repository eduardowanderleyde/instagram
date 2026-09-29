class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_suggestions, if: :user_signed_in?

  def index
    if user_signed_in?
      @posts = Post.where(user: current_user.followings + [current_user])
                   .order(created_at: :desc)
                   .includes(:user, :likes, :comments)
                   .page(params[:page]).per(10)
    else
      @posts = Post.joins(:user).where(users: { private: false })
                   .order(created_at: :desc)
                   .includes(:user, :likes, :comments)
                   .page(params[:page]).per(10)
    end
  end

  private

  def set_suggestions
    follower_ids = current_user.followers.pluck(:id)
    following_ids = current_user.followings.pluck(:id)
    circle_ids = (follower_ids + following_ids).uniq
    excluded_ids = following_ids + [current_user.id]

    # Seguidores e conexões de segundo grau (quem segue / é seguido pelo seu círculo)
    second_degree_ids = Follow.where(accepted: true, follower_id: circle_ids).pluck(:followed_id) +
                        Follow.where(accepted: true, followed_id: circle_ids).pluck(:follower_id)
    random_ids = User.where.not(id: excluded_ids).order(Arel.sql("RANDOM()")).limit(10).pluck(:id)

    candidate_ids = (follower_ids + second_degree_ids + random_ids).uniq - excluded_ids
    @suggestions = User.where(id: candidate_ids.sample(5)).with_attached_profile_pic
  end
end
