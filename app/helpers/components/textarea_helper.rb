module Components::TextareaHelper
  def render_textarea(name:, label: false, id: nil, value: nil, **options)
    options.reverse_merge!(rows: 3, required: false, disabled: false,
                           readonly: false, class: "", label: false,
                           placeholder: t("layouts.component.type"))
    render partial: "components/ui/textarea", locals: {
      label:,
      name:,
      value:,
      id:,
      options:
    }
  end
end
