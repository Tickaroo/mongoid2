class Sportsevent
  include Mongoid::ReadPreference::Extensions
  
  def primary_method
    Mongoid::Threaded.read_preference
  end
  mongoid_read_preference :primary, :primary_method
  
  def other_method
    Mongoid::Threaded.read_preference
  end
  
  def multi_1
    Mongoid::Threaded.read_preference
  end
  
  def multi_2
    Mongoid::Threaded.read_preference
  end
  
  mongoid_read_preference :secondary, [:multi_1, :multi_2]
end