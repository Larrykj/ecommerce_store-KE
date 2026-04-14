class CreateLoyaltyPrograms < ActiveRecord::Migration[7.1]
  def change
    create_table :loyalty_programs do |t|
      t.string :name
      t.decimal :points_per_dollar, default: 1.0
      t.integer :minimum_redemption, default: 100
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :loyalty_tiers do |t|
      t.references :loyalty_program, null: false, foreign_key: true
      t.string :name
      t.integer :min_points
      t.decimal :points_multiplier, default: 1.0
      t.decimal :discount_percent, default: 0
      t.string :badge_color
      t.timestamps
    end

    create_table :loyalty_points do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.integer :points
      t.string :reason
      t.boolean :redeemed, default: false
      t.timestamps
    end

    create_table :loyalty_rewards do |t|
      t.references :loyalty_program, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.integer :points_required
      t.decimal :discount_percent
      t.decimal :discount_amount
      t.integer :max_redemptions
      t.integer :redemption_count, default: 0
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :user_rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :loyalty_reward, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.boolean :used, default: false
      t.timestamps
    end
  end
end
