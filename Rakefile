require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec
desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec)

task :environment do
  require './boot'
end

namespace :cron do
  desc "Fetch nodes from puppetdb"
  task :touch => :environment do
    App.puppetdb.nodes.each do |n|
      remote = Node.new n
      local  = Node.first remote.name
      if !local || remote.report_timestamp != local.report_timestamp
        remote.save
        NodeReportsWorker.perform_async(remote.name)
      end
    end
  end
end

namespace :assets do
  desc 'compile assets'
  task :compile => [:compile_js, :compile_css] do
  end

  desc 'compile javascript assets'
  task :compile_js => :environment do
    sprockets = App.assets
    %w{ application.js vendor.js spec.js }.each do |a|
      asset     = sprockets[a]
      outpath   = App.root.join("public/assets")
      outfile   = Pathname.new(outpath).join("#{a}") # may want to use the digest in the future?
      FileUtils.mkdir_p outfile.dirname
      asset.write_to(outfile)
    end
    puts "successfully compiled js assets"
  end

  desc 'compile css assets'
  task :compile_css => :environment do
    sprockets = App.assets
    %w{ application.css vendor.css vendor/jasmine.css }.each do |a|
      asset     = sprockets[a]
      outpath   = App.root.join("public/assets")
      outfile   = Pathname.new(outpath).join(a) # may want to use the digest in the future?
      FileUtils.mkdir_p outfile.dirname
      asset.write_to(outfile)
    end
    puts "successfully compiled css assets"
  end
  # todo: add :clean_all, :clean_css, :clean_js tasks, invoke before writing new file(s)
end
