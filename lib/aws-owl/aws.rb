module AwsOwl
  class Aws
    attr_accessor :ec2, :class_map

    def initialize
      @ec2 = AWS::EC2.new
    end

    def attr_hash(obj, attrs)
      hash = {}
      attrs.each do |key|
        hash[key] = obj.send(key)
      end

      hash
    end

    def as_hashes(enum, attrs)
      enum.map {|obj| attr_hash(obj, attrs)}
    end

    def instances
      AWS.memoize do
        AwsHash::parse_collection(@ec2.instances)
      end
    end

    def security_groups
      AWS.memoize do
        AwsHash::parse_collection(@ec2.security_groups)
      end
    end
  end

  class AwsHash
    attr_accessor :obj, :hash

    def self.parse_collection(collection)
      klass = nil
      collection.map do |obj|
        klass ||= ClassMap[obj.class]
        if not klass
          raise "Class not in ClassMap: #{obj.class.inspect}"
        end

        parsed = klass.new(obj)
        parsed.hash
      end
    end

    @@classes_seen = {}

    def initialize(obj, norecurse=false)
      @obj = obj

      if not @@classes_seen.include? obj.class
        puts obj.class.inspect
        @@classes_seen[obj.class] = true
      end

      @hash = {}
      attrs.each do |key|
        @hash[key] = obj.send(key)
      end

      # some attributes can be directly turned into hashes (like tags)
      hashable_attrs.each do |key|
        @hash[key] = obj.send(key).to_h
      end

      # Don't recurse if this is a summary to prevent infinite loops.
      return if norecurse

      recurse_collections.each do |key|
        @hash[key] = self.class.parse_collection(obj.send(key))
      end

      summary_collections.each do |key|
        collection = obj.send(key)
        summaries = collection.map do |subobj|
          klass = ClassMap[subobj.class]
          if not klass
            raise "Class not in ClassMap: #{subobj.class.inspect}"
          end

          parsed = klass.new(subobj, true)
          parsed.summary
        end

        @hash[key] = summaries.sort
      end
    end

    def to_yaml
      @hash.to_yaml
    end

    def summary
      summary_attrs.map{|key| @hash[key]}.map(&:to_s).join(' - ')
    end

    def attrs
      [:id]
    end

    def summary_attrs
      [:id]
    end

    def hashable_attrs; [] end

    def recurse_collections; [] end

    def summary_collections; [] end
  end


  class AwsInstance < AwsHash
    def summary
      @obj
    end

    def attrs
      [:id, :instance_type, :api_termination_disabled?,
       :instance_initiated_shutdown_behavior, :image_id, :key_name, :kernel_id,
       :ramdisk_id, :root_device_type, :root_device_name, :private_dns_name,
       :dns_name, :private_ip_address, :ip_address, :status, :architecture,
       :virtualization_type, :reservation_id, :requester_id, :owner_id,
       :monitoring, :state_transition_reason, :launch_time, :platform,
       :hypervisor, :client_token, :vpc_id, :subnet_id]
    end

    def summary_collections
      [:security_groups]
    end

    def hashable_attrs
      [:tags]
    end
  end


  class AwsSecurityGroup < AwsHash
    def attrs
      [:id, :name, :description, :owner_id, :vpc_id]
    end

    def summary_attrs
      [:id, :name]
    end

    def recurse_collections
      [:ingress_ip_permissions, :egress_ip_permissions]
    end
  end


  class AwsIpPermission < AwsHash
    def attrs
      [:protocol, :port_range, :ip_ranges]
    end

    def summary_attrs
      # IpPermissions have no .id
      attrs
    end

    def summary_collections
      [:groups]
    end
  end

  ClassMap = {
    AWS::EC2::Instance => AwsInstance,
    AWS::EC2::SecurityGroup => AwsSecurityGroup,
    AWS::EC2::SecurityGroup::IpPermission => AwsIpPermission,
  }

end
