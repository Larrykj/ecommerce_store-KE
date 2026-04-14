class CreateEmailCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :email_campaigns do |t|
      t.string :name
      t.string :campaign_type
      t.text :subject
      t.text :body
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.integer :recipients_count
      t.integer :opened_count
      t.integer :clicked_count
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :email_campaigns, :campaign_type

    create_table :email_triggers do |t|
      t.string :event_type
      t.string :action
      t.integer :delay_days
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :email_subscriptions do |t|
      t.references :user, foreign_key: true
      t.string :email
      t.string :subscribed_to
      t.boolean :subscribed, default: true
      t.timestamps
    end
    add_index :email_subscriptions, [ :email, :subscribed_to ], unique: true
  end
end
