require "spec_helper"

describe Mongoid::Safety do

  let(:collection) do
    stub
  end

  before do
    Person.stubs(:collection).returns(collection)
    Acolyte.stubs(:collection).returns(collection)
  end

  after do
    Person.unstub(:collection)
    Acolyte.unstub(:collection)
  end

  describe "#add_to_set" do

    let(:person) do
      Person.new.tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$addToSet" => { "aliases" => "Bond" } },
          :w => 2
        )
        person.safely(:w => 2).add_to_set(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$addToSet" => { "aliases" => "Bond" } },
          :w => 1
        )
        person.safely.add_to_set(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#bit" do

    let(:person) do
      Person.new.tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$bit" => { "age" => { :and => 12 } } },
          :w => 2
        )
        person.safely(:w => 2).bit(:age, { :and => 12 })
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$bit" => { "age" => { :and => 12 } } },
          :w => 1
        )
        person.safely.bit(:age, { :and => 12 })
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe ".create" do

    let(:id) do
      BSON::ObjectId.new
    end

    context "when providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => id, "name" => "John" },
          :w => 2
        )
        Acolyte.safely(:w => 2).create(:id => id, :name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => id, "name" => "John" },
          :w => 1
        )
        Acolyte.safely.create(:id => id, :name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe ".create!" do

    let(:id) do
      BSON::ObjectId.new
    end

    context "when providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => id, "name" => "John" },
          :w => 2
        )
        Acolyte.safely(:w => 2).create!(:id => id, :name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => id, "name" => "John" },
          :w => 1
        )
        Acolyte.safely.create!(:id => id, :name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#delete" do

    let(:person) do
      Person.new
    end

    context "when providing options" do

      before do
        collection.expects(:remove).with({ :_id => person.id }, :fsync => true)
        person.safely(:fsync => true).delete
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:remove).with({ :_id => person.id }, :w => 1)
        person.safely.delete
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe ".delete_all" do

    context "when providing options" do

      before do
        collection.expects(:find).with({}).returns([])
        collection.expects(:remove).with({}, :w => 2)
        Person.safely(:w => 2).delete_all
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:find).with({}).returns([])
        collection.expects(:remove).with({}, :w => 1)
        Person.safely.delete_all
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#destroy" do

    let(:person) do
      Person.new
    end

    context "when providing options" do

      before do
        collection.expects(:remove).with({ :_id => person.id }, :fsync => true)
        person.safely(:fsync => true).destroy
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:remove).with({ :_id => person.id }, :w => 1)
        person.safely.destroy
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe ".destroy_all" do

    let(:person) do
      Person.new
    end

    context "when providing options" do

      before do
        collection.expects(:find).with({}, {}).twice.returns([ person ])
        collection.expects(:remove).with({ :_id => person.id }, :fsync => true)
        Person.safely(:fsync => true).destroy_all
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:find).with({}, {}).twice.returns([ person ])
        collection.expects(:remove).with({ :_id => person.id }, :w => 1)
        Person.safely.destroy_all
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#inc" do

    let(:person) do
      Person.new.tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$inc" => { "age" => 2 } },
          :w => 2
        )
        person.safely(:w => 2).inc(:age, 2)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$inc" => { "age" => 2 } },
          :w => 1
        )
        person.safely.inc(:age, 2)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#insert" do

    let(:acolyte) do
      Acolyte.new(:name => "John")
    end

    context "when providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => acolyte.id, "name" => "John" },
          :w => 2
        )
        acolyte.safely(:w => 2).insert
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:insert).with(
          { "_id" => acolyte.id, "name" => "John" },
          :w => 1
        )
        acolyte.safely.insert
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#pop" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pop" => { "aliases" => 2 } },
          :w => 2
        )
        person.safely(:w => 2).pop(:aliases, 2)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pop" => { "aliases" => 2 } },
          :w => 1
        )
        person.safely.pop(:aliases, 2)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#pull" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pull" => { "aliases" => "Bond" } },
          :w => 2
        )
        person.safely(:w => 2).pull(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pull" => { "aliases" => "Bond" } },
          :w => 1
        )
        person.safely.pull(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#pull_all" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pullAll" => { "aliases" => [ "Bond" ] } },
          :w => 2
        )
        person.safely(:w => 2).pull_all(:aliases, [ "Bond" ])
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pullAll" => { "aliases" => [ "Bond" ] } },
          :w => 1
        )
        person.safely.pull_all(:aliases, [ "Bond" ])
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#push" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$push" => { "aliases" => "Bond" } },
          :w => 2
        )
        person.safely(:w => 2).push(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$push" => { "aliases" => "Bond" } },
          :w => 1
        )
        person.safely.push(:aliases, "Bond")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#push_all" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pushAll" => { "aliases" => [ "Bond" ] } },
          :w => 2
        )
        person.safely(:w => 2).push_all(:aliases, [ "Bond" ])
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$pushAll" => { "aliases" => [ "Bond" ] } },
          :w => 1
        )
        person.safely.push_all(:aliases, [ "Bond" ])
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#rename" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$rename" => { "aliases" => "handles" } },
          :w => 2
        )
        person.safely(:w => 2).rename(:aliases, :handles)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$rename" => { "aliases" => "handles" } },
          :w => 1
        )
        person.safely.rename(:aliases, :handles)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#save" do

    let(:acolyte) do
      Acolyte.new.tap do |a|
        a.new_record = false
        a.move_changes
      end
    end

    before do
      acolyte.name = "John"
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 2
        )
        acolyte.safely(:w => 2).save
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 1
        )
        acolyte.safely.save
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#save!" do

    let(:acolyte) do
      Acolyte.new.tap do |a|
        a.new_record = false
        a.move_changes
      end
    end

    before do
      acolyte.name = "John"
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 2
        )
        acolyte.safely(:w => 2).save!
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 1
        )
        acolyte.safely.save!
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#unset" do

    let(:person) do
      Person.new(:aliases => []).tap { |p| p.new_record = false }
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$unset" => { "aliases" => 1 } },
          :w => 2
        )
        person.safely(:w => 2).unset(:aliases)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => person.id },
          { "$unset" => { "aliases" => 1 } },
          :w => 1
        )
        person.safely.unset(:aliases)
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#update_attributes" do

    let(:acolyte) do
      Acolyte.new.tap do |a|
        a.new_record = false
        a.move_changes
      end
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 2
        )
        acolyte.safely(:w => 2).update_attributes(:name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 1
        )
        acolyte.safely.update_attributes(:name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end

  describe "#update_attributes!" do

    let(:acolyte) do
      Acolyte.new.tap do |a|
        a.new_record = false
        a.move_changes
      end
    end

    context "when providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 2
        )
        acolyte.safely(:w => 2).update_attributes!(:name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end

    context "when not providing options" do

      before do
        collection.expects(:update).with(
          { "_id" => acolyte.id },
          { "$set" => { "name" => "John" } },
          :w => 1
        )
        acolyte.safely.update_attributes!(:name => "John")
      end

      it "clears the safety options post persist" do
        Mongoid::Threaded.safety_options.should be_nil
      end
    end
  end
end
