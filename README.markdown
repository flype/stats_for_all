# StatsForAll

StatsForAll gives you a simple way to track all the stats you need from your models.

The plugin was coded with two goals in mind,  be as easier to use as possible and scalable.

## Requirements

  - drb gem
  - demonize gem

  optionally if you want to use starling mode with the queue system you'll need: 
	- Starling gem
	- SimplifiedStarling rails plugin  <http://github.com/fesplugas/simplified_starling>

## Install

In the root directory of your project:

	script/plugin install git://github.com/flype/stats_for_all.git

The installation script will create for you the stats_for_all.yml file in the /config directory of your project where you'll be able to setup all the configuration options Also the installation script will create the migration file to store the stats generated.

## Basic Configuration

To start using it you have to define the model you want to track, I'm going to use for this example a model named banner:

	ruby script/generate model banner string:url
	
In the model you have to add the  command:

	stats_for_me

	app/models/banner.rb:

	class Banner < ActiveRecord::Base
      stats_for_me
	end

In the config file you have to specify the model name and the type with de identifier you want to use for all your models with stats:

	/config/stats_for_all.yml:

	all:
     model: [ banner ]
  	 types: { click: 0, hit: 1}

That's all to have the basic functionality of the plugging running.

## Basic Usage example

To use it you have to know the new methods of your model, continuing with the banner example used before:

You have now 4 new methods to use in your banner model: add_hit, add_click, hits and clicks.
We are going to see and example of use of your click type
	
We create a banner instance:

	Banner.create(:url =>"http://github.com")
	
To increase the counter of your types defined in "stats_for_all.yml" you can use:

	Banner.first.add_click

The counter is increased on by one each time you call the add_click method.
	
To get any stats saved before you can use this syntax, and you will get the 24, 31, 12 vector with all your stats depending on your request.
	
	Banner.first.clicks :day => 28, :month => 10, :year => 2008
	Banner.first.clicks :day => 21, :month =>10, :year => 2008
	Banner.first.clicks :month =>10, :year => 2008
	Banner.first.clicks :year => 2008
		
Also you can specify, ranges of time to get more than one vector at time.

	Banner.first.clicks :day => 21..24, :month =>10..12, :year => 2007..2009

## Scalability features

As I said in the beginning of this document, this plugins was coded with two main goals, be easy to use, as you have seen in the basic usage example and scalability.

Concerning with scalability the plugin have three working modes: direct, drb and starling.

The **direct mode** use the db directly to increase and regenerate all the stats in each "add_type" call. Because of that this mode it's only recommended to development stages because generate a lot of load in the db.

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

## Known issues

Can't run in sqlite.

Nowadays the drb services have a limited number of connections  that may create a bottle neck in your app, because of that I'm planning to support multiple instances of the drb server running at the same time with a system to balance the load to each drb server. By the moment, I think that the starling queue system can normalize the high load peaks.
  
## Running plugin tests

You have to go to the test folder in the plugin and run rake, you will need to have installed the factory-girl plugin and the shoulda testings kits.

## TODO

Test it in different rails version, by the moment tested in 2.1.1
Prepare the multi-drb server support to fight with high load peaks of requests.
Prepare some benchmark about the number of petition supported in each mode.

## Thanks

Guillermo Álvarez for some ideas and inspiration about the design.

## :-)

Please, tell me your experiences, problem, suggestion to improve any aspect of it.

Copyright (c) 2008 [Felipe Talavera Armero <felipe@n2kp3.com>], released under the MIT license
