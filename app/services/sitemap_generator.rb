class SitemapGenerator
  def self.generate
    host = Rails.application.credentials.dig(:domain) || "localhost:3000"
    protocol = Rails.env.production? ? "https" : "http"

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        xml.url do
          xml.loc "#{protocol}://#{host}/"
          xml.changefreq "daily"
          xml.priority "1.0"
        end

        Product.published.find_each do |product|
          xml.url do
            xml.loc "#{protocol}://#{host}/products/#{product.slug}"
            xml.lastmod product.updated_at.strftime("%Y-%m-%d")
            xml.changefreq "weekly"
            xml.priority "0.8"
          end
        end

        Category.kept.find_each do |category|
          xml.url do
            xml.loc "#{protocol}://#{host}/categories/#{category.slug}"
            xml.lastmod category.updated_at.strftime("%Y-%m-%d")
            xml.changefreq "weekly"
            xml.priority "0.7"
          end
        end

        BlogPost.published.find_each do |post|
          xml.url do
            xml.loc "#{protocol}://#{host}/blog/#{post.slug}"
            xml.lastmod post.updated_at.strftime("%Y-%m-%d")
            xml.changefreq "monthly"
            xml.priority "0.6"
          end
        end
      end
    end

    builder.to_xml
  end

  def self.save
    File.open(Rails.root.join("public", "sitemap.xml"), "w") do |f|
      f.write(generate)
    end
  end
end
