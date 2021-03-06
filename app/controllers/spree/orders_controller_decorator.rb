Spree::OrdersController.class_eval do

  # prepend to orders#populate to
  # look for params[:options] and attach the option values
  # to the add_variant call
  def populate_with_options
    @order = current_order(true)

    if params[:options].present? && params[:variants]

      params[:variants].each do |variant_id, quantity|
        if variant = Spree::Variant.find(variant_id)
          quantity = quantity.to_i

          option_values = Spree::OptionValue.find(params[:options].values.map(&:to_i))

          line_item = @order.add_variant(variant, quantity, option_values)

          line_item.customizations = params[:customizations] if params[:customizations]
        end
      end

      params.delete(:variants) # prevent populate_orig from adding again
    end

    populate_without_options
  end

  alias_method_chain :populate, :options

end
