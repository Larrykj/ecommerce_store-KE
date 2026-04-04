class AddReviewCacheToProducts < ActiveRecord::Migration[8.1]
  def change
    # Add cached columns for review data to avoid expensive calculations
    add_column :products, :reviews_count, :integer, default: 0
    add_column :products, :average_rating, :decimal, precision: 3, scale: 2, default: 0

    # Add indices on these columns for filtering/sorting
    add_index :products, :reviews_count
    add_index :products, :average_rating
  end
end
