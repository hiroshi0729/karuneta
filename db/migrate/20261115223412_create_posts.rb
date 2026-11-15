class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.string :title, null: false
      t.text :memo
      t.integer :status, null: false, default: 0
      t.integer :template_type
      t.date :scheduled_on
      t.date :posted_on

      t.timestamps
    end
  end
end
