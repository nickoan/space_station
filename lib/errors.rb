module SpaceStation

  class StateIsUnKnown < Exception
  end

  class NotPassAuthError < StandardError
  end

  class UnknownConfigType < Exception
  end

  class ConfigOperationError < Exception
  end
end