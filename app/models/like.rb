class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validate: :user_id, uniqueness: {scope: :post_id}
end
