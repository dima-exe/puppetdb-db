require 'spec_helper'

describe ReportWorker do
  let(:hash)   { '38ff2aef3ffb7800fe85b322280ade2b867c8d27' }
  let(:attrs)  { node_report_attrs }
  let(:worker) { ReportWorker.new }

  cleanup_redis!

  context "#perform" do
    subject { -> { worker.perform(hash, attrs) } }
    before  do
      mock_puppetdb_events_request hash
      Timecop.freeze(Time.utc(2012, 11, 1))
    end

    it "should create reports" do
      should change{
        r = Report.first(hash)
        r && r.events.first
      }.from(nil).to(hash_including("property" => "ensure"))
    end

    it "should create report summary" do
      should change{
        f = NodeReport.latest(:all).map(&:attrs)
      }.from([]).to([attrs])
    end
  end
end

