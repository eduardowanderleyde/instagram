# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    caption { "Sample Post" }
    longitude { 10.0 }
    latitude { 20.0 }
    allow_comments { true }
    show_likes_count { true }
    association :user

    after(:build) do |post|
      post.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpg')
    end
  end
end
