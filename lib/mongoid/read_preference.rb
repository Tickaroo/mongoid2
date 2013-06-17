# encoding: utf-8
module Mongoid #:nodoc:

  # The +ReadPreference+ module is used to provide a DSL to execute database queries
  # on primary or secondary. 
  module ReadPreference
    extend self
    
    # Accepts a block. All Database queries within the block will be executed 
    # on the primary Cluster Node.
    #
    # @example Set the read preference to primary
    #   Mongoid.with_primary do 
    #     ... some database queries
    #   end
    def with_primary
      preference_temp = Threaded.read_preference
      begin
        Threaded.read_preference = :primary
        yield
      ensure
        Threaded.read_preference = preference_temp
      end
    end
    
    # Accepts a block. All Database queries within the block will be executed 
    # on a secondary Cluster Node.
    #
    # @example Set the read preference to primary
    #   Mongoid.with_secondary do 
    #     ... some database queries
    #   end
    def with_secondary
      preference_temp = Threaded.read_preference
      begin
        Threaded.read_preference = :secondary
        yield
      ensure
        Threaded.read_preference = preference_temp
      end
    end
    
    # Check if a read preference is set and reverse merge it into the given hash. 
    #
    # @example Merge Options
    #   ReadPreference.merge_options(hash)
    #
    # @param [ Hash ] options An options Hash.
    #
    # @return [ Hash ] A merged options Hash.
    def merge_options!(options)
      if Threaded.read_preference
        options[:read] = Threaded.read_preference unless options[:read]
      end
      options
    end

  end
  
end

