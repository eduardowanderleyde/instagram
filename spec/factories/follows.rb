# spec/factories/follows.rb
FactoryBot.define do
  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user
    accepted { false }
  end
end
