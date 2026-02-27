# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :phone, presence: true

  scope :ordered, -> { order(default: :desc, created_at: :desc) }

  # Ensure only one default address per user
  before_save :unset_other_defaults, if: :default?

  def full_address
    parts = [ address_line_1, address_line_2, city, state, postal_code, country ].compact_blank
    parts.join(", ")
  end

  def display_name
    "#{label}: #{address_line_1}, #{city}"
  end

  private

  def unset_other_defaults
    user.addresses.where.not(id: id).update_all(default: false)
  end
end
