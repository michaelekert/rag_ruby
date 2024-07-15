class ApplicationService
  class << self
    def call (*args)
      new(*args).constructor
    end
  end

  attr_reader :result

  def constructor
    @result = call
    self
  end

  def success?
    !failure?
  end

  def failure?
    errors.any?
  end

  def errors
    @errors ||= Errors.new
  end

  def call
    fail NotImplementedError unless defined? super
  end
end