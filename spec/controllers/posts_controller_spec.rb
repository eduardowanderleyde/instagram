# spec/controllers/posts_controller_spec.rb
require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe "GET #index" do
    it "redirects to the root path" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      user = create(:user)
      post = create(:post, user: user)
      sign_in user
      get :show, params: { id: post.id }
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    it "does not let a non-owner update the post" do
      post = create(:post, caption: "original")
      sign_in create(:user)
      patch :update, params: { id: post.id, post: { caption: "hacked" } }
      expect(response).to redirect_to(root_path)
      expect(post.reload.caption).to eq("original")
    end
  end

  describe "DELETE #destroy" do
    it "does not let a non-owner destroy the post" do
      post = create(:post)
      sign_in create(:user)
      expect { delete :destroy, params: { id: post.id } }.not_to change(Post, :count)
    end
  end
end
