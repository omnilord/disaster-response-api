class POD < Resource
  self.table_name = 'resources'
  default_scope { where(resource_type: :pod) }

  def title
    Resource.title_for(:pods)
  end
end
