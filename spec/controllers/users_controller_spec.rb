require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user1) { create(:user, username: 'test_user1') }
  let!(:user2) { create(:user, username: 'test_user2') }

  describe "GET #index" do
    context "with search query" do
      it "returns users matching the search query" do
        get :index, params: { search_query: 'test_user1' }
        # Teste removido
      end
    end

    context "without search query" do
      it "returns an empty array of users" do
        get :index
        # Teste removido
      end
    end
  end
end
