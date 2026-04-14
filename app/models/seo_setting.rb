class SeoSetting < ApplicationRecord
  validates :page_type, uniqueness: true

  def self.for(page_type)
    find_by(page_type: page_type) || new(page_type: page_type)
  end
end
