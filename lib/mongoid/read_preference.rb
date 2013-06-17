# encoding: utf-8
module Mongoid #:nodoc:

  # The +ReadPreference+ module is used to provide a DSL to execute database queries
  # on primary or secondary. 
  module ReadPreference
    extend self
    
    # Accepts a block. All Database queries within the block will be executed 
    # with given read preference.
    #
    # @example Set the read preference to primary
    #   Mongoid.with_read_preference(:primary) do 
    #     ... some database queries
    #   end
    def with_read_preference(read_preference)
      preference_temp = Threaded.read_preference
      begin
        Threaded.read_preference = read_preference
        yield
      ensure
        Threaded.read_preference = preference_temp
      end
    end
     
    # Accepts a block. All Database queries within the block will be executed 
    # on the primary Cluster Node.
    #
    # @example Set the read preference to primary
    #   Mongoid.with_primary do 
    #     ... some database queries
    #   end
    def with_primary
      with_read_preference(:primary) do
        yield
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
      with_read_preference(:secondary) do
        yield
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
    
    module Extensions
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        # Define a read preference for a whole method. 
        # Note: Assignment methods and other special method names ([])
        # are currently not supported.
        #
        # @example Merge Options
        #   mongoid_read_preference :primary, :method_name
        #
        # @param [ Symbol, Symbol ] options Read preference and method name.
        def mongoid_read_preference(read_preference, methods)
          raise "Pleas specifiy at least one method in the :for option" if methods.blank?
          
          methods_to_manipulte = methods.is_a?(Array) ? methods : [methods]
          
          methods_to_manipulte.each do |method|
            visibility = if self.private_instance_methods.map{|s|s.to_sym}.include? method.to_sym
              :private
            elsif self.protected_instance_methods.map{|s|s.to_sym}.include? method.to_sym
              :protected
            else
              :public
            end
          
            method_without_read_preference = "#{method}_without_mongoid_read_preference"
            method_with_read_preference = "#{method}_with_mongoid_read_preference"
          
            class_eval <<-EOC
              def #{method_with_read_preference}(*args, &block)
                Mongoid.with_read_preference(:#{read_preference}) do
                  #{method_without_read_preference}(*args, &block)
                end
              end
            EOC
          
            alias_method method_without_read_preference, method.to_s
            alias_method method, method_with_read_preference
            send visibility, method
            send visibility, method_with_read_preference
          end
        end
        
      end
    end

  end
  
end

