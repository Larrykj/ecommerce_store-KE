class SitemapsController < ApplicationController
  def show
    respond_to do |format|
      format.xml { render xml: SitemapGenerator.generate }
    end
  end
end
