class BlogCategory < ApplicationRecord
  has_many :posts, class_name: "BlogPost", dependent: :nullify

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  before_validation :set_slug

  scope :ordered, -> { order(:position) }

  private

  def set_slug
    self.slug ||= name.parameterize
  end
end
