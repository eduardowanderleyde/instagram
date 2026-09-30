require 'rails_helper'

# Garante que as páginas principais renderizam sem erro de template.
RSpec.describe "Pages smoke test", type: :request do
  let(:user) { create(:user, username: "eduardo", private: false) }
  let(:friend) { create(:user, username: "amigo", private: false) }
  let!(:post_record) do
    create(:post, user: friend).tap do |p|
      p.images.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")), filename: "second.jpg", content_type: "image/jpg")
      p.likes.create!(user: user)
      p.comments.create!(user: user, body: "Que foto!")
    end
  end

  context "when logged out" do
    it "renders the public pages" do
      get root_path
      expect(response).to have_http_status(:ok)

      get new_user_session_path
      expect(response).to have_http_status(:ok)

      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "when logged in" do
    before do
      create(:follow, follower: user, followed: friend)
      create(:follow, follower: create(:user, username: "fa"), followed: user, accepted: false)
      sign_in user
    end

    it "renders the feed with carousel, likes and comments" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Que foto!", 'data-controller="carousel"', "Follow requests")
    end

    it "renders profile, post and settings pages" do
      [user_path(friend), user_path(user), post_path(post_record), edit_user_registration_path].each do |path|
        get path
        expect(response).to have_http_status(:ok), "#{path} returned #{response.status}"
      end
    end

    it "renders search results inside the turbo frame" do
      get users_path(search_query: "ami"), headers: { "Turbo-Frame" => "search_results" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("amigo")
    end
  end
end
