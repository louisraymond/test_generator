class Source < ApplicationRecord
  has_many :questions, dependent: :nullify

  validates :name, presence: true
  validates :source_type, presence: true
end
