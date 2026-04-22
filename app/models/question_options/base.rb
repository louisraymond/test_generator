# Base behaviour for per-type question-options value objects. Each subclass
# wraps the `Question#options` jsonb with a typed interface so Stimulus
# controllers and the paper-editor autosave path can read / write options
# without marshalling raw hashes.
#
# Dual-read: `.from(raw)` must accept both the legacy seed shape and the new
# shape so no seed PR is required to land Wave 3.
module QuestionOptions
  class Base
    def self.from(_raw)
      raise NotImplementedError, "#{self} must implement .from(raw)"
    end

    def to_jsonb
      raise NotImplementedError
    end

    # Subclasses push validation errors onto the passed-in errors object.
    # Matches Question's existing `options_requirements_for_type` pattern so
    # migration can be incremental.
    def validate(_errors); end

    protected

    def self.bool(value)
      !!ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
