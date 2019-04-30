module Polymorphable
  def find_polymorph
    klass, field, name = polymorphic_class
    klass.find_by(field => params[name.to_sym]) if klass
  end

  def extract(polymorph = nil, resource = nil)
    name = params[:controller].split('/').last
    resource_name = params[:id].present? ? name.singularize : name.pluralize
    polymorph_name = polymorph&.class&.name&.underscore


    if polymorph
      nested("#{polymorph_name}_#{resource_name}_url", polymorph, resource)
    else
      regular("#{resource_name}_url", resource)
    end
  end

private

  def polymorphic_class
    params.each do |name, _|
      match = name.match(%r{([^\/.]*)_(slug|id)$})
      return [match[1].classify.constantize, match[2], name] if match
    end
    nil
  end

  def regular(location_url, resource)
    if resource
      send(location_url, resource)
    else
      send(location_url)
    end
  end

  def nested(location_url, polymorph, resource)
    if resource
      send(location_url, polymorph, resource)
    else
      send(location_url, polymorph)
    end
  end
end
