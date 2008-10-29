# StatsForAll

StatsForAll gives you a simple way to track all the stats you need from your models.

The plugin was coded with two goals in mind:  be as easier to use as possible and very scalable.

## Requirements

  - drb gem
  - demonize gem

  Optionally if you want to use starling mode with the queue system you'll need: 
	- Starling gem
	- SimplifiedStarling rails plugin  <http://github.com/fesplugas/simplified_starling>

## Install

In the root directory of your project:

	script/plugin install git://github.com/flype/stats_for_all.git
	
The install script will create a configuration file in /config and one migration, remember to run the migration:

	rake db:migrate

The installation script will create for you the stats_for_all.yml file in the /config directory of your project where you'll be able to setup all the configuration options Also the installation script will create the migration file to store the stats generated.

## Basic Configuration

To start using it you have to define the model you want to track, I'm going to use for this example a model named banner:

	ruby script/generate model banner url:string
	
In the model you have to add the  command:

	stats_for_me

for example like this:

	app/models/banner.rb:

	class Banner < ActiveRecord::Base
      stats_for_me
	end

In the config file you have to specify the models names and the type with de identifier you want to use for all your models with stats, for example:

	/config/stats_for_all.yml:

	all:
     model: [ banner ]
  	 types: { click: 0, hit: 1}

That's all to have the basic functionality of the plugging running.

## Basic Usage example

To use it you have to know the new methods of your model, continuing with the banner example used before:

You have now 4 new methods to use in your banner model: 

	@banner.add_hit
	@banner.add_click
	@banner.hits
	@banner.clicks
	
We are going to see and example of use of your click type.
	
We create a banner instance:

	Banner.create(:url =>"http://github.com")
	
To increase the counter of your types defined in "stats_for_all.yml" you can use:

	Banner.first.add_click
	=>1

The counter is increased on by one each time you call the add_click method.
	
To get the stats array calculated, you can use this syntax, and you will get the 24, 31, 12 vector with all your stats depending on the parameters specified:

Imagine that we added the click the day 28 of  october of 2008 and we want to recover the stats for that day:
	
	Banner.first.clicks :day => 28, :month => 10, :year => 2008
	=> [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]

or other day of the same month, that doesn't have data:	

	Banner.first.clicks :day => 21, :month =>10, :year => 2008
	=> []

or all the october month:

	Banner.first.clicks :month =>10, :year => 2008
	=> [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]

or the stats for the twelve months:

	Banner.first.clicks :year => 2008
	=> [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0]
		
Also you can specify, ranges of time to get more than one vector at time.

	Banner.first.clicks :day => 21..24, :month =>10..12, :year => 2007..2009
	=> [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]]
	
## Scalability features

As I said in the beginning of this document, this plugins was coded with two main goals, be easy to use, as you have seen in the basic usage example and scalability.

Concerning with scalability the plugin have three working modes: **direct**, **drb** and **starling**.

The **direct mode** use the db directly to increase and regenerate all the stats in each "add_type" call. Because of that, this mode it's only recommended to development stages because generate a lot of load in the db.

The **drb mode** use a rake task to enable a drb server where all your increments with the "add_type" will be temporally stored while they are waiting to be dump to the db all in one time.

And finally the third mode, the **starling mode** use a starling queue to give the scalability and the persistence of the starling queue to query our drb server.
To use this feature you need to have installed the starling gem and the rails plugin SimplifiedStarling <http://github.com/fesplugas/simplified_starling>

In the configuration file you can specify which one of this methods use in each one of the rails environment, with the "increment_type:" setting direct, drb or starling in each one of the the environments, also you can change the port and the host that drb server will use and configure the frequency in seconds of the dumps to the db in your drb server.

	/config/stats_for_all.yml:

	all:
	  model: [ banner ]

	  types: { click: 0, hit: 1}

	  # no need if you work in "direct mode" only
	  server_host: localhost
	  server_port: 9000
	  dump_frequency_in_seconds: 600

	development:
	  increment_type: drb #drb, direct, starling

	production:
	  increment_type: starling

	test:
	  increment_type: direct
	
One last consideration, to run the drb server, mandatory in the drb and starling modes, you can use three rake task

To start the drb server in background in the terminal

	rake stats_for_all:start

To stop the drb server in background in the terminal

	rake stats_for_all:stop

To run in foreground in the terminal

	rake stats_for_all:run
	
If you want to run in starling mode you can use the rake task provided by the simplified_starling plugin to run and stop the queue and the queue processor, remember:
	
To run the processor and the starling queue:
	
	rake simplified_starling:start_and_process_jobs 
	
To stop both:
	
	rake simplified_starling:stop
	rake simplified_starling:stop_processing_jobs 
	
More info about simplified_starling plugin in their own repository <http://github.com/fesplugas/simplified_starling>

## Benchmarks

Finally, I have made some benchmark of the implementation:

	mode-number         user     system      total        real
	direct-10        0.090000   0.010000   0.100000 (  0.159613)
	direct-100       0.910000   0.060000   0.970000 (  1.560477)
	direct-1000      8.830000   0.580000   9.410000 ( 15.582841)
	direct-10000    86.100000   5.830000  91.930000 (161.467011)
	drb-10           0.010000   0.000000   0.010000 (  0.027090)
	drb-100          0.130000   0.010000   0.140000 (  0.244915)
	drb-1000         1.570000   0.110000   1.680000 (  3.055996)
	drb-10000       15.420000   0.980000  16.400000 ( 28.404083)
	starling-10      0.010000   0.000000   0.010000 (  0.006791)
	starling-100     0.010000   0.010000   0.020000 (  0.035332)
	starling-1000    0.120000   0.040000   0.160000 (  0.384227)
	starling-10000   1.420000   0.340000   1.760000 (  4.374145)

As you can see there is some big performance diferences between each mode.

## Known issues

Can't run in sqlite.

Nowadays the drb services have a limited number of connections  that may create a bottle neck in your app, because of that I'm planning to support multiple instances of the drb server running at the same time with a system to balance the load to each drb server. By the moment, I think that the starling queue system can normalize the high load peaks.
  
## Running plugin tests

You have to go to the test folder in the plugin and run rake, you will need to have installed the factory-girl plugin and the shoulda testings kits.

## TODO

Add ACL to the drb server.

Test it in different rails version, by the moment tested in 2.1.1.

Prepare the multi-drb server support to fight with high load peaks of requests.

## Thanks

Guillermo Álvarez - for some ideas and inspiration about the design.

## :-)

Please, tell me your experiences, problem, suggestion to improve any aspect of it.

Copyright (c) 2008 [Felipe Talavera Armero <felipe@n2kp3.com>], released under the MIT license
