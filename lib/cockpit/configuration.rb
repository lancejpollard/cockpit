module Cockpit
  module Configuration
  
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      
      attr_accessor :setting_class, :configurable
      
      def setting_class
        @setting_class ||= ::Setting
      end
      
      def initialize(*args, &block)
        store.tree = args.extract_options!
        value      = args
        build(&block)
      end
      
      def build(&block)
        tree.instance_eval(&block) if block_given?
      end
      
      def configurable=(object)
        @configurable = object
        store.configurable = object
      end
      
      # something like this
      # Settings.for(@user.id).set(:allow_email => params[:allow_email])
      # or
      # @user.settings(:allow_email => params[:allow_email])
      def for(configurable_id)
        self
      end
      
      def each_setting(&block)
        tree.each_setting(&block)
      end
      
      def tree
        store.tree
      end
      
      def defaults
        store.defaults
      end
      
      def store
        self.store = :memory if @store.nil?
        @store
      end
      
      def empty?
        tree.empty?
      end
      
      def store=(value)
        options = {:configurable => configurable}
        options[:tree] = @store.tree unless @store.nil?
        @store = case value
        when :memory
          Cockpit::Store::Memory.new(self, options)
        when :db
          Cockpit::Store::Database.new(self, options)
        else
          value
        end
      end
      
      def get(path)
        store.get(path)
      end
      alias_method :[], :get
    
      def get!(path)
        store.get!(path)
      end
    
      def set(value)
        store.set(value)
      end
      
      def set!(value)
        store.set!(value)
      end
    
      def []=(key, value)
        store.set(key => value)
      end
      
      def clear(options = {})
        store.clear(options)
      end
      
      def inspect
        "<##{self.class.to_s} @tree=#{tree.inspect}/>"
      end
      
      def to_yaml
        to_hash.to_yaml
      end
      
      def to_hash
        store.tree.to_hash
      end
      
      def method_missing(meth, *args, &block)
        if args.empty?
          store.get(meth)
        else
          store.set(meth, args.first)
        end
      end
      
    end
  
    module ClassMethods
      
      def setting_class
        global.setting_class
      end
      
      def global(&block)
        @global ||= new
        @global.build(&block)
        @global
      end
      
      def define!(*args, &block)
        options = args.extract_options!
        path = args.first
        if path && !path.is_a?(Hash) && !block_given?
          global[path]
        elsif !options.empty?
          global.set(options)
        else
          global(&block)
        end
      end
      
      # something like this
      # Settings.for(@user.id).set(:allow_email => params[:allow_email])
      # or
      # @user.settings(:allow_email => params[:allow_email])
      def for(name)
        Settings.new(get(name).dup)
      end
      
      def tree
        global.tree
      end
      
      def defaults
        global.defaults
      end
      
      def store
        global.store
      end
      
      def store=(value)
        global.store = value
      end
      
      def get(path)
        global.get(path)
      end
      alias_method :[], :get
    
      def get!(path)
        global.get!(path)
      end
    
      def set(value)
        global.set(value)
      end
      
      def set!(value)
        global.set!(value)
      end
    
      def []=(key, value)
        global.set(key => value)
      end
      
      def clear(options = {})
        global.clear(options)
      end
      
      def empty?
        global.empty?
      end
      
      def inspect
        global.inspect
      end
      
      def to_yaml
        global.to_yaml
      end
      
      def to_hash
        global.to_hash
      end
      
      def method_missing(meth, *args, &block)
        global.method_missing(meth, *args, &block)
      end
      
    end
  end
end
