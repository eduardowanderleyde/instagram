# spec/models/comment_spec.rb
require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:comment) { build(:comment, user: user, post: post, body: "This is a comment") }

  describe 'Validations' do
    it 'is valid with valid attributes' do
      expect(comment).to be_valid
    end

    it 'is not valid without a body' do
      comment.body = nil
      expect(comment).not_to be_valid
    end

    it 'is not valid without a user' do
      comment.user = nil
      expect(comment).not_to be_valid
    end

    it 'is not valid without a post' do
      comment.post = nil
      expect(comment).not_to be_valid
    end
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end
end
