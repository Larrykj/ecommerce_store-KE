module ApplicationHelper
  def seo_meta(title, description = nil)
    title = "#{title} - #{t('app.name')}" if title.present?
    provide(:title, title)
    provide(:meta_description, description) if description.present?
  end

  def blog_featured_image_source(featured_image)
    return if featured_image.blank?

    source = featured_image.to_s.strip
    return if source.blank?

    return source if source.match?(%r{
      \A(?:https?://|data:image/)
    }ix)

    return source if source.start_with?("/")

    nil
  end

  def blog_featured_image_tag(featured_image, **options)
    source = blog_featured_image_source(featured_image)
    return unless source

    image_tag(source, **options)
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
