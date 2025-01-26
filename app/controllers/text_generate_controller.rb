class TextGenerateController < ApplicationController
  def generate
    @es_service = ElasticSearchService.new
    @es_service.index_data

    render json: { message: "Dados gerados com sucesso." }
  end
end
