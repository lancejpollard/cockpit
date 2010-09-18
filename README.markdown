<h1>Cockpit <img src='http://imgur.com/oXAb6.png' width='16' height='15'/></h1>

> Super DRY Settings for Ruby, Rails, and Sinatra Apps with pluggable backend support.

## Install

    sudo gem install cockpit

## How it works

You can define arbitrarily nested key/value pairs of any type, and customize them from an Admin panel or the terminal, and save them to the MySQL, MongoDB, Redis, in memory, or even a File.

1. Settings can be associated with a model class
2. Settings can be associated with a model instance, which can use the model class settings as defaults
3. Settings can be global and not reference a model at all (basic key/value store).

You define settings like this:

    Cockpit :active_record do
      site do
        title "My Site"
        time_zone :default => lambda { "Hawaii" }
        feed do
          per_page 10
          formats %w(rss atom)
        end
      end
    end

That gives you an instance of `Cockpit::Settings`, a tree data structure.

## Global Settings API

If you've defined your `:active_record` settings like above, which are _global_ settings, you can use them like this:

### Get Methods

    Cockpit::Settings["site.feed.per_page"] #=> 10
    Cockpit::Settings("site.feed.per_page") #=> 10
    Cockpit::Settings.site.feed.per_page.value #=> 10
    
Everything ultimately passes through the hash form of the method, `Cockpit::Settings["path"]`, so that's the most optimized way to do it.

You can also check to see if these settings exist:

    Cockpit::Settings.site.feed.per_page? #=> true

### Set Methods

    Cockpit::Settings["site.feed.per_page"] = 20
    Cockpit::Settings("site.feed.per_page", 20)
    Cockpit::Settings.site.feed.per_page.value = 20
    
### Behind the Scenes

When you define settings using the DSL, they get stored as `Cockpit::Spec` objects into a global hash in the `Cockpit::Settings` class, which is a dictionary of `specs[class][name] = spec`.  Global specs aren't associated with a class (e.g. model class), so the `class` is `NilClass`.  You can have multiple global settings classes if you'd like, just give them names:

    Cockpit :store => :active_record, :name => :more_settings do
      hello "world"
    end
    
You can access specific global settings like this:

    Cockpit::Settings.find(:more_settings).hello.value #=> "world"
    
## Instance Settings API

You can also associate settings with any object (plain Object, ActiveRecord, MongoMapper::Document, etc.):

    class User < ActiveRecord::Base
      include Cockpit
      
      cockpit do
        preferences do
          favorite_color "red"
        end
        settings do
          birthday :after => :queue_birthday_message, :if => lambda { |key, value|
            value =~ /\d\d\/\d\d\/\d\d\d\d/ # 10/03/1986
          }
          number_of_children, Integer
        end
      end
      
      def queue_birthday_message(key, value)
        BirthdayMailer.enqueue(value # ,...)
      end
    end
    
And access them like this:

    user = User.new
    user.cockpit["settings.number_of_children"] #=> 300
    user.cockpit["preferences.favorite_color"] = "green"
    user.cockpit.settings.number_of_children.value = 0
    user.cockpit.preferences? #=> true
    
If your model class doesn't have methods named after the cockpit keys, it will generate methods for you and delegate them to the `cockpit`:

    user.preferences.favorite_color? #=> true
    user.settings? #=> true
    user.preferences.favorite_color.value = "turquoise"
    
## Swappable Backend

The current backends supported are these keys:

- active_record
- mongo
- memory

Soon, or as need be, I'll support redis, files, couchdb, etc.  Haven't needed them yet.

## Caching

For Active Record, Cockpit just adds a `has_many :settings` declaration to your model, and loads all of the settings on the first call, caching any further gets to settings for that model.  This means basically that settings are extendable database attributes for your model.
    
## Use Cases

This makes it really easy to edit random settings from an interface, such as an admin panel.  Next goal is to add callbacks around save/destroy so you can run processes when settings are changed (such as changing your google_analytics, which would require re-rendering views if they were cached).

The goal is to make this [enormous configuration dsl work](http://gist.github.com/558432), so I can define an entire site in a DSL.

### Other API Notes

When you specify the DSL, that creates a flat tree of defaults, which aren't saved to the database.  Then when you update the setting, it saves to the database, otherwise when the value is read and is null, it will use the default from the in-memory/dsl-defined tree.

You can also associate a hash with each setting definition.  This is great for say options, defaults, titles and tooltips, etc.  Here's an example:

    Cockpit :active_record do
      site do
        time_zones "MST", :options => Proc.new { TZInfo::Timezone.all.map(&:name) }
      end
    end
    
    assert_equal TZInfo::Timezone.all.map(&:name), Cockpit::Settings["site.time_zones"][:options].call
    
And you can access the definition object directly:

    Cockpit::Settings.definition("site.time_zones").attributes[:options]
    
You can even do this in the terminal:

    irb -r 'rubygems'
    require 'cockpit'
    Cockpit { site { title "Lance" } }
    puts Cockpit::Settings["site.title"] #=> "Lance"
    
<cite>copyright [@viatropos](http://viatropos.com) 2010</cite>