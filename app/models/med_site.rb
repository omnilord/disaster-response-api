class MedSite < Resource
  self.table_name = 'resources'
  default_scope { where(resource_type: :medsite) }

  def title
    Resource.title_for(:medsites)
  end
end
