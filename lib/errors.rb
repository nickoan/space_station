module SpaceStation

  class StateIsUnKnown < Exception
  end

  class NotPassAuthError < Exception
  end

  class UnknownConfigType < Exception
  end

  class ConfigOperationError < Exception
  end

  class PermissionDeniedError < Exception
  end

  class UnknownSequenceTypeError < Exception
  end
end