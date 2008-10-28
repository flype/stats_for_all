# StatsForALL

StatsForAll gives you a simple way to track all the stats you need from your models.

The plugin was coded with two goals in mind,  be as easier to use as possible and scalable.

## Requirements

  - Ruby >= 1.8.5
  - drb gem
  - demonize gem
  - optionally if you want to use starling queue system you'll need the rails plugin simplified_starling http://github.com/fesplugas/simplified_starling 

## Install

In the root directory of your project:

	script/plugin install git://github.com/flype/stats_for_all.git

The installation script will create for you the stats_for_all.yml file in the /config directory of your project where you'll be able to setup all the configuration options Also the installation script will create the migration file to store the stats generated.

## Basic Configuration

To start using it you have to define the model you want to track, I'm going to use for this example a model named banner:

	ruby script/generate model banner string:url
	
In the model you have to add the "stats_for_me":

app/models/banner.rb:

	class Banner < ActiveRecord::Base
  	stats_for_me
	end

In the config file in /config/stats_for_all.yml you have to specify the model name and the type with de identifier you want to use for all your models with stats:

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
	
To increase the counter of your types defined in stats_for_all.yml you can use:
	Banner.first.add_click
The counter is increased on by one each time you call the add_click method.
	
To get any stats saved before you can use this syntax, and you will get the 24, 31, 12 vector with all your stats depending on your request.
	Banner.first.clicks :day => 28, :month => 10, :year => 2008
  Banner.first.clicks :day => 21, :month =>10, :year => 2008
  Banner.first.clicks :month =>10, :year => 2008
  Banner.first.clicks :year => 2008
		
Also you can specify, ranges of time to get more than one vector at time.
  Banner.first.clicks :day => 21..24, :month =>10..12, :year => 2007..2009

##

## Known issues

  - You can get race conditions in the version keys of tables stored in Memcached
  
## Running plugin tests



## TODO


## Special Thanks

Copyright (c) 2008 [Felipe Talavera Armero <felipe@n2kp3.com>], released under the MIT license
