# http://www.daniel-azuma.com/blog/view/z3bqa0t01uugg1/implementing_dsl_blocks
module Cockpit  
  class TreeHash < Hash
    
    def initialize
      block = Proc.new {|h,k| h[k] = TreeHash.new(&block)}
      super &block
    end
    
    def value_type
      has_key?(:type) ? self[:type] : :string
    end
    
    def each_setting(&block)
      dup.each do |k, v|
        atrib = Hash.new
        if v.has_key?(:value)
          value = clone(v[:value])
          atrib = clone(v)
        else
          v.each do |k, sub_v|
            atrib[k] = clone(v[k]) unless sub_v.is_a?(TreeHash)
          end
          value = clone(v)
        end
        yield(k.to_s, atrib, value) if block_given?
      end
    end
    
    def dup
      result = super
      result.each do |k,v|
        result[k] = v.dup if v.is_a?(TreeHash)
      end
      result
    end
    
    def children
      hash = {}
      each do |k, v|
        hash[k] = v if v.is_a?(Hash)
      end
      hash
    end
    
    def get(key)
      traverse(key)
    end
    
    def get_attribute(key, attribute)
      get(key)[attribute.to_sym]
    end

    def set(key, value)
      traverse(key, value)
    end
    
    def set_attribute(key, value)
      traverse(key, value, false)
    end
    
    def set_attributes(hash)
      hash.each { |k, v| set_attribute(k, v) }
      self
    end
    
    def to_hash
      hash = {}
      self.each do |k, v|
        hash[k] = v.is_a?(TreeHash) ? v.to_hash : v
      end
      hash
    end
    
    protected
      def traverse(path, value = nil, as_node = true)
        path = path.to_s.split('.')
        child = path.pop.to_sym
        parent = path.inject(self) { |h,k| h[k.to_sym] }
        unless value.nil?
          if as_node
            if parent[child].has_key?(:type)
              parent[child][:value] = Cockpit.type_cast(value, parent[child][:type])
            else
              parent[child][:value] = value
              parent[child][:type]  = Cockpit.get_type(value)
            end
          else
            parent[child] = value
          end
        end
        parent[child]
      end
      
      def method_missing(meth, *args, &block)
        options = args.extract_options!
        meth    = meth.to_s.gsub("=", "").to_sym
        if args.empty?
          return self[meth] if self.has_key?(meth)
          found = get(meth).set_attributes(options)
          found = found.instance_eval(&block) if block_given?
          found
        else
          get(meth).set_attributes({:type => Cockpit.get_type(args.first)}.merge(options).merge(:value => args.first))
        end
      end
      
    private
      def clone(object)
        (object.respond_to?(:dup) ? object.dup : object) rescue object
      end
  end
end