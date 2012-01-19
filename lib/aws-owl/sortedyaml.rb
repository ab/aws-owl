require 'yaml'

# not needed in ruby 1.9... sigh
class Symbol
  include Comparable

  def <=>(other)
    self.to_s <=> other.to_s
  end
end

class Hash
  # Replace the to_yaml function so it sorts hashes by keys
  #
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v|   # <-- here's my addition (the 'sort')
          map.add( k, v )
        end
      end
    end
  end
end
