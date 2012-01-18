module AwsOwl
  class OwlLogger < Logger
    def initialize(name)
      super(STDERR)
      self.level = 0
    end
  end
end
