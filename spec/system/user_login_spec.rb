# spec/system/user_login_spec.rb
require 'rails_helper'

RSpec.describe "UserLogins", type: :system do
  it "allows a user to log in" do
    user = create(:user)
    visit new_user_session_path
    fill_in "Phone number, username or email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log In"
    expect(page).to have_content "Signed in successfully"
  end
end
