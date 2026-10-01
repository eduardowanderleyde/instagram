require 'rails_helper'

RSpec.describe "Sign out", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
    get root_path # grava o cookie de sessão (o sign_in de teste só vale para a 1ª requisição)
  end

  it "does not sign out via GET (avoids logout CSRF)" do
    get destroy_user_session_path
    expect(response).to have_http_status(:not_found)

    get edit_user_registration_path
    expect(response).to have_http_status(:ok)
  end

  it "signs out via DELETE" do
    delete destroy_user_session_path, headers: { "Accept" => "text/html" }
    expect(response).to be_redirect

    get edit_user_registration_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
