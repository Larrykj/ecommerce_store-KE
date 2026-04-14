class OverlapValidator < ActiveModel::Validator
  def validate(record)
    return unless record.start_time && record.end_time

    # Find overlapping flash sales (excluding self if updating)
    overlapping = FlashSale.where(active: true)
      .where("start_time < ? AND end_time > ?", record.end_time, record.start_time)

    # Exclude self when updating
    overlapping = overlapping.where.not(id: record.id) if record.persisted?

    if overlapping.exists?
      record.errors.add(:base, "This flash sale overlaps with another active sale")
    end
  end
end
