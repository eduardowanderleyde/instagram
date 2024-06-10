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
      get :show, params: { id: post.id }
      expect(response).to be_successful
    end
  end
end
