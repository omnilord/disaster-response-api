#
# Draft Handler for draftable items
#
# Implementation details:
# - resource variable in the controller for CRUD should be
#   the same as `controller_name.classify.underscore` or
#   this will have a false positive for drafts existing.
#

module DraftHandler
  extend ActiveSupport::Concern

  def save_or_draft(method)
    class_name = controller_name.classify
    name = class_name.underscore
    class_params = self.send("#{name}_params")

    @draft, success, pending, error_render =
      if method == :create
        [
          Draft.new(draftable_type: class_name.constantize, data: class_params),
          :new_success, :new_draft_pending, :new
        ]
      else
        obj = self.instance_variable_get("@#{name}")
        [
          Draft.new(draftable: obj, data: class_params),
          :update_success, :update_draft_pending, :edit
        ]
      end

    if @draft.save
      if @draft.approve
        obj = @draft.draftable
        self.instance_variable_set("@#{name}", obj)
        redirect_to obj, notice: I18n.t(success, type: "`#{obj.draft_type}` #{I18n.t(name.to_sym)}")
      else
        redirect_to @draft, notice: I18n.t(pending, draft: I18n.t(name.to_sym))
      end
    else
      flash[:error] = @draft.errors.full_messages || I18n.t(:generic_error)
      render error_render
    end
  end

  def set_draft_count_warning
    obj = self.instance_variable_get("@#{controller_name.classify.underscore}")
    @draft_count = Draft.where(draftable: obj).actionable.count
    if @draft_count > 0
      drafts_label = ActionController::Base.helpers.pluralize(@draft_count, t(:draft))
      flash[:warning] =
        if admin?
          I18n.t(:drafts_exist_url, url: url_for([obj, :drafts]), drafts: drafts_label)
        else
          I18n.t(:drafts_exist, drafts: drafts_label)
        end
    end
  end
end
