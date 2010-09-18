<h1>Cockpit <img src='http://imgur.com/oXAb6.png' width='16' height='15'/></h1>

> Super DRY Settings for Ruby, Rails, and Sinatra Apps with pluggable backend support.

## How it works

You can define arbitrarily nested key/value pairs of any type, and customize them from an Admin panel or the terminal, and save them to the MySQL, MongoDB, Redis, or even a File.

1. Settings can be associated with a model class
2. Settings can be associated with a model instance, which can use the model class settings as defaults
3. Settings can be global and not reference a model at all (basic key/value store).

You define settings like this:

    settings = Cockpit :mongo do
      site do
        title "My Site"
        time_zone lambda { "Hawaii" }
        feed do
          per_page 10
          formats %w(rss atom)
        end
      end
    end

That gives you [this data structure](http://gist.github.com/558480), which is accessed internally as a flat hash with keys like this:

    ["site.feed.formats", "site.time_zone", "site.feed.per_page", "site", "site.feed", "site.title"]
       
## Global and Instance Settings

By default you will have 1 set of global settings, accessible via `Cockpit::Settings.root` which is populated in this call:

    Cockpit :mongo do
      site do
        author "Lance"
      end
    end
    
If you want to have settings encapsulated in an independent scope, you can just assign that to a variable:

    site_settings = Cockpit :mongo do
      site do
        author "Lance"
      end
    end
    
## Associated Settings with Models

You can also associate settings with any object (plain Object, ActiveRecord, MongoMapper::Document, etc.):

    class User < ActiveRecord::Base
      include Cockpit
      
      cockpit :mongo do
        preferences do
          favorite_color "red"
        end
        settings do
          google_analytics "123123123"
        end
      end
    end
    
And access them like this:

    user = User.new
    user.cockpit["settings.google_analytics"] #=> "123123123"
    user.cockpit["preferences.favorite_color"] = "green"
    
## Swappable Backend

Thanks to the work behind Moneta, there's a clear interface to key/value stores (and some people have added ActiveRecord support which I've included in this).

The current backends supported are these keys:

- mongodb (or 'mongo')
- redis
- active_record
- file
- memory
- yaml

It should be easy enough to wrap the rest of the Moneta adapters.

This is specified as the first DSL attribute:

    Cockpit :redis do
      site do
        author "Lance"
      end
    end
    
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