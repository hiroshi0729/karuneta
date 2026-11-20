class CreateSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :slides do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :label, null: false
      t.string :heading
      t.text :body

      t.timestamps
    end
    # 同じネタの中でスライドの順番が重ならないようにする
    add_index :slides, %i[post_id position], unique: true
  end
end
