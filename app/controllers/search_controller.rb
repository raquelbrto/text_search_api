class SearchController < ApplicationController
  def search_complex
    @search_service = ElasticSearchService.new
    @results = @search_service.search_complex(params[:query])

    render json: @results
  end

  def search_simple
    @search_service = ElasticSearchService.new
    @results = @search_service.search_simple(params[:query])

    render json: @results
  end
end
