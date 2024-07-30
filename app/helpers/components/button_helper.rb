module Components::ButtonHelper
  def render_button(label = "", text: nil, variant: :default, as: :button,
    href: nil, data: {}, **options, &block)
    button_classes = "text-sm font-medium ring-offset-background rounded-md
                      transition-colors focus-visible:outline-none inline-flex
                      focus-visible:ring-2 focus-visible:ring-ring items-center
                      focus-visible:ring-offset-2 h-10 px-4 py-2 justifyF-center
                      disabled:pointer-events-none disabled:opacity-50"
    variant_classes = case variant.to_sym
                      when :default
                        "bg-primary text-primary-foreground
                        hover:bg-primary/90"
                      when :secondary
                        " bg-secondary text-secondary-foreground
                        hover:bg-secondary/80 "
                      when :error, :danger, :alert, :destructive
                        " bg-destructive text-destructive-foreground
                        hover:bg-destructive/90 "
                      when :outline
                        "  border border-input bg-background hover:bg-accent
                        hover:text-accent-foreground"
                      when :ghost
                        " hover:bg-accent hover:text-accent-foreground  "
                      end
    button_classes = tw(button_classes, variant_classes, options[:class])

    text = label if label.present?
    text = capture(&block) if block
    render "components/ui/button", text:, button_classes:, as:, href:, data:,
**options
  end
end
