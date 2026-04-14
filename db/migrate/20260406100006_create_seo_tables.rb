class CreateSeoTables < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :meta_title, :string
    add_column :products, :meta_description, :text
    add_column :categories, :meta_title, :string
    add_column :categories, :meta_description, :text

    create_table :seo_settings do |t|
      t.string :page_type
      t.string :meta_title
      t.text :meta_description
      t.text :extra_tags
      t.timestamps
    end
    add_index :seo_settings, :page_type, unique: true
  end
end
