class Topic < ApplicationRecord
  include Topic::LearningObjectiveManagement
  include Topic::OutlineNormalization
  include Topic::Presentation

  attribute :module_aims, :json, default: []
  attribute :learning_outcomes, :json, default: []
  attribute :syllabus_outline, :json, default: []
  attribute :reference_links, :json, default: []

  belongs_to :parent_topic, class_name: 'Topic', optional: true
  has_many :subtopics, class_name: 'Topic', foreign_key: :parent_topic_id, dependent: :nullify

  has_many :topic_modules, -> { order(position: :asc) }, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :learning_objectives, -> { order(:category_order, :position, :id) }, dependent: :destroy

  accepts_nested_attributes_for :learning_objectives, allow_destroy: true
  accepts_nested_attributes_for :topic_modules, allow_destroy: true

  validates :name, presence: true
end
