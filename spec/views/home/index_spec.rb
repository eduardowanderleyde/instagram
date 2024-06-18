# spec/views/home/index_spec.rb
require 'rails_helper'

RSpec.describe "home/index", type: :view do
  let(:user) { create(:user) }
  let(:feeds) { create_list(:post, 3, user: user) }
  let(:suggestions) { create_list(:user, 2) }

  before do
    # Mock current_user
    allow(view).to receive(:current_user).and_return(user)

    # Set up instance variables required for the view
    assign(:feeds, feeds)
    assign(:suggestions, suggestions)

    # Render the view
    render
  end

  it "renders the flash messages partial" do
    expect(view).to render_template(partial: "layouts/_flash_messages")
  end

  it "renders the stories list partial" do
    expect(view).to render_template(partial: "story/_stories_list")
  end

  it "renders the post partial for each feed" do
    expect(view).to render_template(partial: "posts/_post", count: 3)
  end

  it "renders the suggestions list partial" do
    expect(view).to render_template(partial: "suggestions/_suggestions_list")
  end
end
