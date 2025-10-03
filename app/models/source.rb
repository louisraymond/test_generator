class Source < ApplicationRecord
  has_many :questions, dependent: :nullify
end
