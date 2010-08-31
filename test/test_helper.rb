require "rubygems"
require "ruby-debug"
gem 'test-unit'
require "test/unit"
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'
require 'shoulda/active_record'

require File.dirname(__FILE__) + '/lib/database'
require File.expand_path(File.join(File.dirname(__FILE__), '/../lib/cockpit'))
require File.dirname(__FILE__) + '/lib/user'

class Object
  include Cockpit
end

ActiveRecord::Base.class_eval do
  def self.detonate
    all.map(&:destroy)
  end
end

ActiveSupport::TestCase.class_eval do
  
  def load_settings
    Cockpit do
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
      site do
        title "Martini"
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
      social do
        facebook "http://facebook.com/viatropos"
        twitter "http://twitter.com/viatropos"
        email "lancejpollard@gmail.com"
      end
    end
  end
end