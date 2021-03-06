require 'faraday'
require 'faraday_middleware'
require 'uri'
require 'cgi'

module App
  class PuppetDB
    class << self
      def inst
        @inst ||= PuppetDB.new
      end
    end

    def query_resource(name, title = nil)
      if title
        get("resources/#{name}/#{title}")
      else
        get("resources/#{name}")
      end
    end

    def nodes
      get "nodes"
    end

    def facts(node)
      App.cache "cache:#{node}:facts" do
        get "nodes/#{node}/facts"
      end
    end

    def reports(name)
      query "reports", "=", 'certname', name
    end

    def report(report_id)
      App.cache "cache:report:#{report_id}", ttl: 0 do
        query "events", "=", 'report', report_id
      end
    end

    def metrics
      App.cache "cache:metrics" do
        num_nodes = metric("com.puppetlabs.puppetdb.query.population:type=default,name=num-nodes")
        num_resources = metric("com.puppetlabs.puppetdb.query.population:type=default,name=num-resources")
        avg_resources_per_node = metric("com.puppetlabs.puppetdb.query.population:type=default,name=avg-resources-per-node")
        {
          "num_nodes" => num_nodes,
          "num_resources" => num_resources,
          "avg_resources_per_node" => avg_resources_per_node
        }

      end
    end

    def search_facts(params)
      op = params[:operator] || '='
      field = params[:field] || 'name'
      q = params[:query]
      query = %{["#{op}", "#{field}", "#{q}"]}
      get 'facts?query=' + CGI.escape(query)
    end

    private
      def conn
        @conn ||= begin
          _conn = Faraday.new host do |c|
            c.use FaradayMiddleware::ParseJson, content_type: 'application/json'
            c.use Faraday::Response::Logger if %w{ development }.include?(App.env)
            c.use Faraday::Response::RaiseError
            c.use Faraday::Adapter::NetHttp
          end
          _conn.headers[:accept] = 'application/json'
          _conn
        end
      end

      def host
        ENV['PUPPETDB_URL'] || 'http://localhost:8080'
      end

      def get(url, options = {})
        conn.get("/v2/#{url}", options).body
      end

      def query(url, *q)
        q = %{query=["#{q[0]}","#{q[1]}","#{q[2]}"] }
        conn.get("/experimental/#{url}?" + URI.encode(q)).body
      end

      def metric(name)
        conn.get("/metrics/mbean/#{name}").body["Value"]
      end
  end
end
