class CommentsController < ApplicationController
  before_action :set_post, only: [:create]

  def create
    @comment = @post.comments.create(user: current_user, body: params[:comment_body])

    respond_to do |format|
      format.turbo_stream do 
        render turbo_stream: turbo_stream.replace(
          "post#{@post.id}comments",
          partial: "posts/post_comments",
          locals: { post: @post }
        )
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.user == current_user
      @comment.destroy

      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream: turbo_stream.remove(
            "post#{@comment.post_id}ModalComment#{@comment.id}"
          )
        end
        format.html { redirect_to @comment.post and return }
      end
    else
      redirect_to @comment.post, alert: "Você não tem permissão para excluir este comentário."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
