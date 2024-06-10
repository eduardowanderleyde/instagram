require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }

  before do
    sign_in user
  end

  describe "POST #toggle_like" do
    context "when the user likes the post" do
      it "creates a like" do
        expect {
          post :toggle_like, params: { post_id: post_record.id }, format: :turbo_stream
        }.to change(Like, :count).by(1)
      end

      it "renders the turbo stream response" do
        post :toggle_like, params: { post_id: post_record.id }, format: :turbo_stream
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
      end
    end

    context "when the user unlikes the post" do
      before do
        post_record.likes.create(user: user)
      end

      it "destroys the like" do
        expect {
          post :toggle_like, params: { post_id: post_record.id }, format: :turbo_stream
        }.to change(Like, :count).by(-1)
      end

      it "renders the turbo stream response" do
        post :toggle_like, params: { post_id: post_record.id }, format: :turbo_stream
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
      end
    end
  end
end
