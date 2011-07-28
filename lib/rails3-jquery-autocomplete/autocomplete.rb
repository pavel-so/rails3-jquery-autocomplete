require "yajl"

module Rails3JQueryAutocomplete

  # Inspired on DHH's autocomplete plugin
  #
  # Usage:
  #
  # class ProductsController < Admin::BaseController
  #   autocomplete :brand, :name
  # end
  #
  # This will magically generate an action autocomplete_brand_name, so,
  # don't forget to add it on your routes file
  #
  #   resources :products do
  #      get :autocomplete_brand_name, :on => :collection
  #   end
  #
  # Now, on your view, all you have to do is have a text field like:
  #
  #   f.text_field :brand_name, :autocomplete => autocomplete_brand_name_products_path
  #
  #
  module ClassMethods
    def autocomplete(object, method, options = {}, &block)

      define_method("autocomplete_#{object}_#{method}") do
        if block_given?
          options = options.merge yield
        end
        method = options[:column_name] if options.has_key?(:column_name)

        term = params[:term]

        if term && !term.empty?
          #allow specifying fully qualified class name for model object
          class_name = options[:class_name] || object
          items = get_autocomplete_items(:model => get_object(class_name), \
            :options => options, :term => term, :method => method)
            if options[:uniq]
              if options[:display_value]
                items = items.uniq_by{|i| i.send(options[:display_value])}
              else
                items = items.uniq_by{|i| i.send(method)}
              end
            end
        else
          items = {}
        end

        render :json => Yajl::Encoder.encode(json_for_autocomplete(items, options[:display_value] ||= method, options[:extra_data]))
      end
    end
  end

end
module Enumerable
  def uniq_by
    seen = {}
    select { |v|
      key = yield(v)
      (seen[key]) ? nil : (seen[key] = true)
    }
  end
end

