# spec/models/follow_spec.rb
require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end

  describe 'callbacks' do
    context 'when followed user is private' do
      it 'does not accept the follow request' do
        follower = create(:user)
        followed = create(:user, private: true)
        follow = Follow.create(follower: follower, followed: followed)

        expect(follow.accepted).to be_falsey
      end
    end

    context 'when followed user is not private' do
      it 'automatically accepts the follow request' do
        follower = create(:user)
        followed = create(:user, private: false)
        follow = Follow.create(follower: follower, followed: followed)

        expect(follow.accepted).to be_truthy
      end
    end
  end

  describe 'instance methods' do
    it 'accepts a follow request' do
      follow = create(:follow, accepted: false)
      follow.accept

      expect(follow.accepted).to be_truthy
    end
  end
end
