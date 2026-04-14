module ApplicationHelper
  def seo_meta(title, description = nil)
    title = "#{title} - #{t('app.name')}" if title.present?
    provide(:title, title)
    provide(:meta_description, description) if description.present?
  end

  def structured_data(product)
    {
      "@context": "https://schema.org/",
      "@type": "Product",
      "name": product.name,
      "description": product.description,
      "image": product.images.attached? ? url_for(product.images.first) : nil,
      "offers": {
        "@type": "Offer",
        "priceCurrency": "USD",
        "price": product.variants.minimum(:price),
        "availability": product.in_stock? ? "https://schema.org/InStock" : "https://schema.org/OutOfStock"
      }
    }.to_json
  end

  def breadcrumbs(*items)
    content_tag(:nav, class: "breadcrumb") do
      items.map { |item| content_tag(:span, item, class: "breadcrumb-item") }.join.html_safe
    end
  end
end
