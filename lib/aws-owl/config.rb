module AwsOwl
  class Config
    attr_accessor :opts

    def default_config
      paths = ['~/.aws-owl.yaml', '/etc/aws-owl/config.yaml']
      paths.map! {|path| File.expand_path(path)}

      file = paths.find {|path| File.exist? path}

      if not file
        message = "Could not find config. Tried #{paths.inspect}"
        raise AwsOwl::Error.new message
      end

      file
    end

    def initialize(config_file=nil)
      @file = config_file || default_config

      @opts = YAML.load_file(@file)
    end

    def config!
      if ! @opts || ! @opts[:aws]
        raise AwsOwl::Error.new "No key :aws in config."
      end
      AWS.config @opts[:aws]
    end
  end
end

