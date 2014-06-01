class Guests < ActiveRecord::Base
  validates_inclusion_of :dev_type, in: %w(turtle computer)
  validates_uniqueness_of :label
end
