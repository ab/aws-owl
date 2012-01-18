module AwsOwl
  class Aws
    def initialize
      @ec2 = AWS::EC2.new
    end

    def instances
      @ec2.instances.to_a
    end
  end
end
