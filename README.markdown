# Cockpit

<q>Super DRY Settings for Ruby, Rails, and Sinatra Apps.</q>

## Install

    sudo gem install cockpit
    
## Usage

### Migration

    create_table :settings, :force => true do |t|
      t.string :key
      t.string :value
      t.string :cast_as
      t.string :configurable_type
      t.integer :configurable_id
    end

### Setup (`config/initializers/settings.rb`)

    Cockpit do
      site do
        title "Martini", :tooltip => "Set your title!"
        tagline "Developer Friendly, Client Ready Blog with Rails 3"
        keywords "Rails 3, Heroku, JQuery, HTML 5, Blog Engine, CSS3"
        copyright "© 2010 Viatropos. All rights reserved."
        timezones :value => lambda { TimeZone.first }, :options => lambda { TimeZone.all }
        date_format "%m %d, %Y"
        time_format "%H"
        week_starts_on "Monday", :options => ["Monday", "Sunday", "Friday"]
        language "en-US", :options => ["en-US", "de"]
        touch_enabled true
        touch_as_subdomain false
        google_analytics ""
        teasers :title => "Teasers" do
          disable false
          left 1, :title => "Left Teaser"
          right 2
          center 3
        end
        main_quote 1
      end
      asset :title => "Asset (and related) Settings" do
        thumb do
          width 100, :tip => "Thumb's width"
          height 100, :tip => "Thumb's height"
        end
        medium do
          width 600, :tip => "Thumb's width"
          height 250, :tip => "Thumb's height"
        end
        large do
          width 600, :tip => "Large's width"
          height 295, :tip => "Large's height"
        end
      end
      authentication :title => "Authentication Settings" do
        use_open_id true
        use_oauth true
      end
      front_page do
        slideshow_tag "slideshow"
        slideshow_effect "fade"
      end
      page do
        per_page 10
        feed_per_page 10
      end
      people do
        show_avatars true
        default_avatar "/images/missing-person.png"
      end
      social do
        facebook "http://facebook.com/viatropos"
        twitter "http://twitter.com/viatropos"
      end
      s3 do
        key "my_key"
        secret "my_secret"
      end
    end

#### Get

    Settings.get("site.title").value        #=> "Martini"
    Settings.get("site.title.value")        #=> "Martini"
    Settings("site.title").value            #=> "Martini"
    Settings("site.title.value")            #=> "Martini"
    Settings["site.title"].value            #=> "Martini"
    Settings["site.title.value"]            #=> "Martini"
    Settings.site.title.value               #=> "Martini" # doesn't pass through store yet
    
#### Set

    Settings.set("site.title" => "Martini") #=> {:site => {:title => {:value => "Martini"}}}
    Settings("site.title" => "Martini")     #=> {:site => {:title => {:value => "Martini"}}}
    Settings["site.title"] = "Martini"      #=> {:site => {:title => {:value => "Martini"}}}
    Settings.site.title = "Martini"         #=> {:site => {:title => {:value => "Martini"}}} # doesn't pass through store yet

### Key points

- Each node is any word you want
- You can nest them arbitrarily deep
- You can use Procs
- Values are type casted
- Settings can be defined in yaml or using the DSL.
- The preferred way to _get_ values is `Settings("path.to.value").value`
- You can add custom properties to each setting:
  - `Settings("site.title").tooltip #=> "Set your title!"`
- You have multiple storage options:
  - `Settings.store = :db`: Syncs setting to/from ActiveRecord
  - `Settings.store = :memory`: Stores everything in a Hash (memoized, super fast)
- You can specify them on a per-model basis:

    class User < ActiveRecord::Base
      acts_as_configurable :settings do
        name "Lance", :title => "First Name", :options => ["Lance", "viatropos"]
        favorite do
          color "red"
        end
      end
    end
    
    User.new.settings #=> <#Settings @tree={
      :favorite => {
        :color => {:type=>:string, :value=>"red"}
      },
      :name => {:type=>:string, :title=>"First Name", :value=>"Lance", :options=>["Lance", "Viatropos"]}
    }/>
    
### Why

There's no standard yet for organizing random properties in Rails apps.  And settings should be able to be modified through an interface (think Admin panel).

Cockpit encapsulates the logic common relating to:

- Options
- Preferences
- Settings
- Configuration
- Properties and Attributes
- Key/Value stores

Sometimes you need a global store, sometimes that global store needs to be customizable by the user, sometimes each user has their own set of configurations.  This handles all of those cases.

## Todo

- Settings should be sorted by the way they were constructed
- Check type, so when it is saved it knows what to do.

This ended up being very similar to i18n:

- [http://guides.rubyonrails.org/i18n.html](http://guides.rubyonrails.org/i18n.html)
- [I asked about this on the i18n lighthouse](http://i18n.lighthouseapp.com/projects/14947/tickets/21-abstract-out-configuration-functionality-from-i18n-into-separate-gem#ticket-21-1)

I think the i18n gem should be broken down into two parts: Configuration (key/value store), and Translation.

#### End Goal

- Base key-value functionality gem, which allows you to store arbitrary key values in any database (similar to moneta).
- i18n and Cockpit build on top of that

### Alternatives

- [Preferences](http://github.com/pluginaweek/preferences)
- [SettingsGoo](http://rubygems.org/gems/settings-goo)
- [RailsSettings](http://github.com/Squeegy/rails-settings)
- [SimpleConfig](http://github.com/lukeredpath/simpleconfig)
- [Configatron](http://github.com/markbates/configatron)
- [RConfig](http://github.com/rahmal/rconfig)
- [Serenity](http://github.com/progressions/serenity)