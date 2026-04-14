class BlogPost < ApplicationRecord
  belongs_to :user
  belongs_to :category, class_name: "BlogCategory", optional: true
  has_many :comments, class_name: "BlogComment", foreign_key: "post_id", dependent: :destroy

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  before_validation :set_slug

  scope :published, -> { where(published: true).where("published_at <= ?", Time.current) }
  scope :recent, -> { order(published_at: :desc) }

  def excerpt_text
    excerpt.presence || content.to_s.truncate(200)
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug ||= title.parameterize
  end
end
