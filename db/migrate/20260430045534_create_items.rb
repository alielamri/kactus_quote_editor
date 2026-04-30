class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2, default: 0, null: false
      t.decimal :vat_rate, precision: 5, scale: 2, default: 20.0, null: false
      t.references :quote, null: false, foreign_key: true

      t.timestamps
    end
  end
end