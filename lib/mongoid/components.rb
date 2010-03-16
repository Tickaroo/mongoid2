# encoding: utf-8
module Mongoid #:nodoc
  module Components #:nodoc
    extend ActiveSupport::Concern
    included do
      # All modules that a +Document+ is composed of are defined in this
      # module, to keep the document class from getting too cluttered.
      include ActiveModel::Conversion
      include ActiveModel::Naming
      include ActiveModel::Serialization
      include Mongoid::Associations
      include Mongoid::Attributes
      include Mongoid::Callbacks
      include Mongoid::Commands
      include Mongoid::Extras
      include Mongoid::Fields
      include Mongoid::Indexes
      include Mongoid::Matchers
      include Mongoid::Memoization
      include Mongoid::State
      include Mongoid::Validations
      include Observable
      extend ActiveModel::Translation
      extend Mongoid::Finders
      extend Mongoid::NamedScope
    end
  end
end
