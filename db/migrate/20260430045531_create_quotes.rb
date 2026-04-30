class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.string :name, null: false
      t.integer :status, default: 0, null: false
      t.bigint :user_id

      t.timestamps
    end
    add_index :quotes, :user_id
    add_index :quotes, :status
  end
end
