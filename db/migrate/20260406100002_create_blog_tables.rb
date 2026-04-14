class CreateBlogTables < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :blog_categories, :slug, unique: true

    create_table :blog_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, foreign_key: { to_table: :blog_categories }
      t.string :title
      t.string :slug
      t.text :excerpt
      t.text :content
      t.string :featured_image
      t.string :meta_title
      t.text :meta_description
      t.boolean :published, default: false
      t.datetime :published_at
      t.integer :views_count, default: 0
      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :published

    create_table :blog_comments do |t|
      t.references :post, null: false, foreign_key: { to_table: :blog_posts }
      t.references :user, foreign_key: true
      t.string :name
      t.string :email
      t.text :content
      t.boolean :approved, default: true
      t.references :parent, foreign_key: { to_table: :blog_comments }
      t.timestamps
    end
    add_index :blog_comments, :approved
  end
end
