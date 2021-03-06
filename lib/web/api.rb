module App
  class Api < App::Web

    before do
      content_type 'application/json'
    end

    get '/stats/monthly' do
      json ReportMonthly.stats
    end

    get '/nodes' do
      json Node.latest(:report)
    end

    get '/reports' do
      scope = (params["scope"] || :active).to_sym
      json NodeReport.latest(scope, limit: 30)
    end

    get '/nodes/:node' do |node|
      json Node.first node
    end

    get '/nodes/:node/stats/monthly' do |node|
      json ReportMonthly.stats(node: node)
    end

    get '/nodes/:node/facts' do |node|
      json client.facts(node)
    end

    get '/nodes/:node/reports' do |node|
      json NodeReport.latest(:active, node, limit: 30)
    end

    get '/nodes/:node/reports/:report' do |node, report|
      json Report.first(report)
    end

    get '/query' do
      if res = params['resource']
        re = /^([^\[]+)(\[(.*)\])?/
        if m  = res.match(re)
          json client.query_resource(m[1], m[3])
        end
      end
    end


    private
      def json(body)
        body.to_json
      end

      def client
        App.puppetdb
      end

      def params
        @params ||= request.env['rack.request.query_hash']
      end
  end
end
