# spec/views/posts/form_spec.rb
require 'rails_helper'

RSpec.describe "posts/_form", type: :view do
  let(:user) { create(:user) }
  let(:post) { Post.new }

  before do
    sign_in user
    assign(:post, post)
    allow(view).to receive(:current_user).and_return(user)
  end

  it "renders the form with all expected fields" do
    render partial: "posts/form", locals: { post: post }

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("input[type='file'][id='post-images']")
    expect(rendered).to have_selector("textarea[name='post[caption]']")
    expect(rendered).to have_selector("input[name='post[location]']")
    expect(rendered).to have_selector("input[type='checkbox'][name='post[allow_comments]']")
    expect(rendered).to have_selector("input[type='checkbox'][name='post[show_likes_count]']")
    expect(rendered).to have_selector("input[type='submit'][value='Post']")
  end
end
