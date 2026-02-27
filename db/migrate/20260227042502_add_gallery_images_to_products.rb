# Active Storage handles gallery_images through the active_storage_attachments table.
# This migration is a no-op placeholder to document the change.
# The actual change is in the Product model: has_many_attached :gallery_images
class AddGalleryImagesToProducts < ActiveRecord::Migration[8.1]
  def change
    # No schema change needed — Active Storage uses polymorphic attachments table
  end
end
