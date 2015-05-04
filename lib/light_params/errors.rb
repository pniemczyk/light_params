module LightParams
  module Errors
    BaseError = Class.new(StandardError)
    ValueTransformationError = Class.new(BaseError)
    MissingCollectionError   = Class.new(BaseError)
    MissingParamError        = Class.new(BaseError)
    JsonParseError           = Class.new(BaseError)
  end
end
