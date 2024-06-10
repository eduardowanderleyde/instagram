require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password"
    )
    expect(user).to be_valid
  end

  it "is not valid without an email" do
    user = User.new(
      email: nil,
      password: "password"
    )
    expect(user).to_not be_valid
  end

  it "is not valid without a password" do
    user = User.new(
      email: "test@example.com",
      password: nil
    )
    expect(user).to_not be_valid
  end

  describe 'Associations' do
    it { should have_many(:posts) }
    it { should have_many(:likes) }
    it { should have_many(:comments) }
    it { should have_one_attached(:profile_pic) }
    it { should have_many(:follow_requests).class_name('Follow').with_foreign_key('followed_id') }
    it { should have_many(:accepted_recieved_requests).class_name('Follow').with_foreign_key('followed_id') }
    it { should have_many(:accepted_sent_requests).class_name('Follow').with_foreign_key('follower_id') }
    it { should have_many(:waiting_sent_requests).class_name('Follow').with_foreign_key('follower_id') }
    it { should have_many(:followers).through(:accepted_recieved_requests).source(:follower) }
    it { should have_many(:followings).through(:accepted_sent_requests).source(:followed) }
    it { should have_many(:waiting_followings).through(:waiting_sent_requests).source(:followed) }
  end

  describe 'Instance Methods' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe '#follow' do
      it 'follows another user' do
        expect {
          user.follow(other_user)
        }.to change { Follow.count }.by(1)
      end

      it 'does not follow the same user twice' do
        user.follow(other_user)
        expect {
          user.follow(other_user)
        }.not_to change { Follow.count }
      end
    end

    describe '#unfollow' do
      before do
        user.follow(other_user)
      end

      it 'unfollows a followed user' do
        expect {
          user.unfollow(other_user)
        }.to change { Follow.count }.by(-1)
      end

      it 'does nothing if the user is not followed' do
        another_user = create(:user)
        expect {
          user.unfollow(another_user)
        }.not_to change { Follow.count }
      end
    end

    describe '#cancel_request' do
      before do
        user.follow(other_user)
      end

      it 'cancels a follow request' do
        expect {
          user.cancel_request(other_user)
        }.to change { Follow.count }.by(-1)
      end

      it 'does nothing if there is no pending follow request' do
        another_user = create(:user)
        expect {
          user.cancel_request(another_user)
        }.not_to change { Follow.count }
      end
    end
  end
end
