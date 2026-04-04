# frozen_string_literal: true

class AddDiscardedAtToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :discarded_at, :datetime
    add_index :categories, :discarded_at
  end
end
