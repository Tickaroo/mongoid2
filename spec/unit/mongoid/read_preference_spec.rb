require "spec_helper"

describe Mongoid::ReadPreference do
  context "merge_options!" do
    it "should not merge read preference if it already present" do
      options = {:read => :secondary}
      Mongoid.with_primary do
        Mongoid::ReadPreference.merge_options!(options)
      end
      options[:read].should eq(:secondary)      
    end
    
    it "should merge read preference if it isn't present" do
      options = {}
      Mongoid.with_primary do
        Mongoid::ReadPreference.merge_options!(options)
      end
      options[:read].should eq(:primary)
    end
  end
  
  context "with_primary" do
    it "should set Threaded.read_preference within the block to primary" do
      Mongoid::Threaded.read_preference.should eq(nil)
      Mongoid.with_primary do 
        Mongoid::Threaded.read_preference.should eq(:primary)
      end
      Mongoid::Threaded.read_preference.should eq(nil)
    end
  end
  
  context "with_secondary" do
    it "should set Threaded.read_preference within the block to secondary" do
      Mongoid::Threaded.read_preference.should eq(nil)
      Mongoid.with_secondary do 
        Mongoid::Threaded.read_preference.should eq(:secondary)
      end
      Mongoid::Threaded.read_preference.should eq(nil)
    end
  end

  context "secondary nested in primary block" do
    before(:each) do
      Mongoid.with_primary do 
        @first = Mongoid::Threaded.read_preference
        Mongoid.with_secondary do
          @second = Mongoid::Threaded.read_preference
        end
        @third = Mongoid::Threaded.read_preference
      end
    end
    
    it "should set read preference to secondary within secondary block" do
      @first.should eq(:primary)
    end
    
    it "should set read preference to primary before secondary block" do
      @second.should eq(:secondary)
    end
    
    it "should set read preference to primary after secondary block" do
      @third.should eq(:primary)
    end
  end
  
end