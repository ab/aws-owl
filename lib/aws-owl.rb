require 'rubygems'
require 'aws-sdk'
require 'logger'
require 'yaml'

$:.unshift File.dirname(__FILE__)

# load these first
require 'aws-owl/errors'
require 'aws-owl/logger'
require 'aws-owl/config'
require 'aws-owl/sortedyaml'

require 'aws-owl/aws'

module AwsOwl
  attr_accessor :config, :aws, :data

  class Owl
    def initialize
      @config = AwsOwl::Config.new
      @config.config!
      @aws = AwsOwl::Aws.new
      @data = {}
    end

    def interrogate_aws
      @data[:instances] = @aws.instances

    end

    def write_data
      @data.each do |key, values|
        File.open(key.to_s + '.yaml', 'w') do |io|
          YAML.dump(values, io)
        end
      end
    end

    def find_changes
    end

    def update_git
    end
  end
end
