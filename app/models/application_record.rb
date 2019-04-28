class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
  end

  def humanize_enum(enum_name)
    self.class.human_enum_name(enum_name, self.send(enum_name))
  end
end
