module Components::InputHelper
  def render_input(name:, label: false, id: nil, type: :text, value: nil,
    **options)
    options[:class] = build_class(options)
    options = merge_default_options(options)

    render partial: "components/ui/input", locals: {
      type:,
      label:,
      name:,
      value:,
      id:,
      options:
    }
  end

  private

  def build_class options
    base_class = "flex h-10 w-full rounded-md border border-input bg-background
                  px-3 py-2 text-sm transition-colors ring-offset-background
                  h-10 file:bg-transparent file:text-sm file:font-medium
                  placeholder:text-muted-foreground disabled:cursor-not-allowed
                  disabled:opacity-50 file:border-0"
    variant_class = case options[:variant]
                    when :borderless
                      "focus-visible:outline-none focus-visible:shadow-none
                      focus-visible:ring-transparent border-0"
                    else
                      "focus-visible:outline-none focus-visible:ring-2
                      focus-visible:ring-ring focus-visible:ring-offset-2
                      focus-visible:border-muted shadow-sm"
                    end
    tw("#{base_class} #{options[:class]} #{variant_class}")
  end

  def merge_default_options options
    default_options = {
      label: false,
      required: false,
      disabled: false,
      readonly: false,
      placeholder: "",
      autocomplete: "",
      autocapitalize: nil,
      autocorrect: nil,
      autofocus: nil
    }
    options.reverse_merge!(default_options)
  end
end
