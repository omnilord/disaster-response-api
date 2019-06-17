class Shelter < Resource
  self.table_name = 'resources'
  default_scope { where(resource_type: :shelter) }

  def title
    Resource.title_for(:shelters)
  end
end
