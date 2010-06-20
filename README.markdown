# Cockpit

This is to define both application and user defined settings.

It can store them in memory and in the database.

It encapsulates the logic common to:

- Options
- Preferences
- Settings
- Configuration
- Properties and Attributes

It is to store random, hard to categorize properties/options/settings.  They can be arbitrarily nested.

They can be defined in yaml, or using a basic DSL.

Sometimes you need a global store, sometimes that global store needs to be customizable by the user, sometimes each user has their own set of configurations.  This handles all of those cases.

## Todo

- Settings should be sorted by the way they were constructed
- Check type, so when it is saved it knows what to do.

## Usage/API

Each Setting/Property/Option acts the same: they are a key associated with a value, associated with a context (`configurable_type`, `configurable_id`).

In the prototype tree, you can define extra settings that shouldn't change between settings (tooltips for example, or titles for forms, etc.)

This means each node in the tree must be a hash:

    {
      :site => {
        :titles => {
          :main => {
            :value => "Martini",
            :tip => "Title your site!"
          },
          :contact_form => {
            :value => "Contact Us",
            :options => ["Contact Us", "Email Us", "Send us something"]
          }
        }
      }
    }
    
If the node doesn't have a `:value` key, then it is not a setting, it has settings somewhere down the chain.

If you set a value, it will result with this:

    Settings("lance.j.pollard" => "person") #=> {:lance => {:j => {:pollard => {:value => "person"}}}}
    Settings("lance.j.pollard") #=> {:value => "person"}
    Settings("lance.j.pollard.value") #=> "person"
    
## Syntax

#### Setting

    Settings.set("site.title" => "Martini") #=> {:site => {:title => {:value => "Martini"}}}
    Settings("site.title" => "Martini")     #=> {:site => {:title => {:value => "Martini"}}}
    Settings["site.title"] = "Martini"      #=> {:site => {:title => {:value => "Martini"}}}
    Settings.site.title = "Martini"         #=> {:site => {:title => {:value => "Martini"}}} # doesn't pass through store yet
    
#### Getting

    Settings.get("site.title").value        #=> "Martini"
    Settings.get("site.title.value")        #=> "Martini"
    Settings("site.title").value            #=> "Martini"
    Settings("site.title.value")            #=> "Martini"
    Settings["site.title"].value            #=> "Martini"
    Settings["site.title.value"]            #=> "Martini"
    Settings.site.title.value               #=> "Martini" # doesn't pass through store yet
    
## Stores

These can hook into different persistence stores in case you want to be able to change these through an admin panel, are on a read-only filesystem, or want them user-dependent.

    Settings.store = :db # Setting will save record to database, getting will check database if it's blank
    Settings.store = :memory # Default, saves everything into TreeHash

### Migrations

    t.string :key # string, used to build them into a tree
    t.text :value # text

### Todo

This ended up being very similar to i18n:

- [http://guides.rubyonrails.org/i18n.html](http://guides.rubyonrails.org/i18n.html)
- [I asked about this on the i18n lighthouse](http://i18n.lighthouseapp.com/projects/14947/tickets/21-abstract-out-configuration-functionality-from-i18n-into-separate-gem#ticket-21-1)

I think the i18n gem should be broken down into two parts: Configuration (key/value store), and Translation.

#### End Goal for Ruby Community

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