class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.boolean :accepted

      t.timestamps
    end
  end
end
