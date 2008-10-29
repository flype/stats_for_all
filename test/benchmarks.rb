#!/usr/bin/env ruby
# first of all you must have running all the services, remember!:
# rake stats_for_all:start
# rake simplified_starling:start_and_process_jobs

require 'benchmark'
require 'starling'
require File.expand_path(File.dirname(__FILE__) + '/stats_for_all_test_helper') 
require File.expand_path(File.dirname(__FILE__) + '/../../simplified_starling/lib/simplified_starling')
require File.expand_path(File.dirname(__FILE__) + '/../../simplified_starling/lib/simplified_starling/active_record')

times=[10, 100, 1000, 10000]
modes=%w(direct drb starling)

setup_db

@banner=Factory(:banner)

Benchmark.bm(15) do |x|
  modes.each do | mode |
    StatsForAll::CONFIGURATION["increment_type"]=mode
    times.each do |n|
      sleep 4 unless mode=="direct"
      x.report("#{mode}-#{n}") do
        n.times do
          @banner.add_hit
        end
      end
    end
  end
end

teardown_db