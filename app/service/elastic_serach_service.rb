require "faker"

class ElasticTextPerformance
    INDEX_NAME = "text_performance".freeze


    def index_data
      data = generate_text_data(10000)
      bulk_index_data(client, data)
    end

    def generate_metrics
      metrics = performance_metrics(client)
      puts "Status do cluster: #{metrics[:cluster_status]}"

      metrics
    end

    def bulk_index_data(client, data)
      data.each_slice(100) do |batch|
        client.bulk(body: batch)
        puts "Indexados #{batch.size} documentos."
      end
    end

    def create_index
      ES.indices.create(index: INDEX_NAME, body: {
        settings: {
          analysis: {
            analyzer: {
              custom_analyzer: {
                type: "standard",
                stopwords: "_none_"
              }
            }
          }
        },
        mappings: {
          properties: {
            title: { type: "text", analyzer: "custom_analyzer" },
            content: { type: "text", analyzer: "custom_analyzer" },
            length: { type: "integer" }
          }
        }
      })
      puts "Índice '#{INDEX_NAME}' criado."
    end

    def index_exists?
        ES.indices.exists?(index: INDEX_NAME)
    end

    def search_simple(client, term)
        ES.search(index: "text_performance", body: {
          query: {
            match: {
              content: term
            }
          }
        })
    end

    def search_complex(client, terms)
      ES.search(index: "text_performance", body: {
          query: {
            multi_match: {
              query: terms,
              fields: %w[title content],
              fuzziness: "AUTO"
            }
          }
        })
    end

    def generate_text_data(num_docs = 1000)
      (1..num_docs).map do |i|
        {
          index: { _index: "text_performance", _id: i },
          data: {
            title: Faker::Book.title,
            content: Faker::Lorem.paragraphs(number: 50).join(" "),
            length: 50 * 100
          }
        }
      end
    end

    def performance_metrics(client)
      stats = ES.nodes.stats
      cluster_health = ES.cluster.health

      {
        cluster_status: cluster_health["status"],
        total_docs: ES.count(index: "text_performance")["count"],
        heap_used_percent: stats["nodes"].values.first["jvm"]["mem"]["heap_used_percent"],
        cpu_percent: stats["nodes"].values.first["os"]["cpu"]["percent"]
      }
    end
end
