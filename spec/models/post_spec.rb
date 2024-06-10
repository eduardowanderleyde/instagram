# spec/models/post_spec.rb
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  it "is valid with valid attributes" do
    post = Post.new(user: user)
    post.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpg')
    expect(post).to be_valid
  end

  it "is not valid without a user" do
    post = Post.new
    post.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpg')
    expect(post).not_to be_valid
  end

  it "is not valid without images" do
    post = Post.new(user: user)
    expect(post).not_to be_valid
  end
end
