class BlogComment < ApplicationRecord
  belongs_to :post, class_name: "BlogPost"
  belongs_to :user, optional: true
  belongs_to :parent, class_name: "BlogComment", optional: true
  has_many :replies, class_name: "BlogComment", foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true

  scope :approved, -> { where(approved: true) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
end
