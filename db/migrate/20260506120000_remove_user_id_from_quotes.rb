class RemoveUserIdFromQuotes < ActiveRecord::Migration[8.1]
  def change
    remove_index :quotes, :user_id, if_exists: true
    remove_column :quotes, :user_id, :bigint
  end
end
