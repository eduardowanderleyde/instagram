require 'rails_helper'


RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "assigns the correct suggestions" do
      followed_user = create(:user)
      create(:follow, follower: user, followed: followed_user)

      get :index
      suggestions = assigns(:suggestions)

      expect(suggestions).not_to be_nil
      expect(suggestions).to include(followed_user)
      expect(suggestions).not_to include(user)
      expect(suggestions).not_to include(*user.followings)
    end
  end
end
