require "spec_helper"

describe Mongoid::Collection do

  describe "#initialize" do

    context "when providing options" do

      let(:capped) do
        described_class.new(
          Person,
          "capped_people",
          :capped => true, :size => 10240, :max => 100
        )
      end

      let(:options) do
        capped.options
      end

      it "sets the capped option" do
        options["capped"].should be_truthy
      end

      it "sets the capped size" do
        puts capped.options.inspect
        options["size"].should eq(10240)
      end

      it "sets the max capped documents" do
        options["max"].should eq(100)
      end
    end
  end
end
