class LikesController < ApplicationController
  before_action :set_post
  before_action :authorize_viewer!

  def toggle_like
    if (@like = @post.likes.find_by(user: current_user))
      @like.destroy
    else
      @post.likes.create(user: current_user)
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "post#{@post.id}actions",
          partial: "posts/post_actions",
          locals: { post: @post }
        )
      }
      format.html { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def authorize_viewer!
    head :forbidden unless @post.user.visible_to?(current_user)
  end
end
