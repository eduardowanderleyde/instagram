require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let(:user) { create(:user, private: true) }
  let(:follower) { create(:user) }
  let!(:follow_request) { create(:follow, follower: follower, followed: user) }

  describe "POST #accept_follow" do
    it "accepts a request addressed to the current user" do
      sign_in user
      post :accept_follow, params: { follow_id: follow_request.id }
      expect(follow_request.reload.accepted).to be true
    end

    it "does not let another user accept the request" do
      sign_in create(:user)
      expect {
        post :accept_follow, params: { follow_id: follow_request.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(follow_request.reload.accepted).to be false
    end
  end

  describe "DELETE #decline_follow" do
    it "does not let another user decline the request" do
      sign_in create(:user)
      expect {
        delete :decline_follow, params: { follow_id: follow_request.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Follow.exists?(follow_request.id)).to be true
    end
  end
end
