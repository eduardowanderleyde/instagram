require 'rails_helper'

RSpec.describe "Account settings", type: :request do
  let(:user) { create(:user, password: "password123", private: true) }

  before { sign_in user }

  it "saves the extra profile fields" do
    put user_registration_path, params: {
      user: { full_name: "Novo Nome", bio: "Minha bio", private: "0", current_password: "password123" }
    }

    user.reload
    expect(user.full_name).to eq("Novo Nome")
    expect(user.bio).to eq("Minha bio")
    expect(user.private).to be false
  end
end
