class Guest < ActiveRecord::Base
  validates_inclusion_of :dev_type, in: %w(turtle computer)
  validates_uniqueness_of :label

  def generate_label
    raise "Can't generate label without dev_type" unless dev_type
    self.label = "#{dev_type}-#{id}"
  end

  def description
    "#{dev_type} #{label} (ID #{id})"
  end
end
