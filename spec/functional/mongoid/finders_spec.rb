require "spec_helper"

describe Mongoid::Finders do

  before do
    Person.delete_all
    Blog.delete_all
    Post.delete_all
  end

  describe "#find" do

    context "when eager loading in a default scope" do

      before(:all) do
        Mongoid.identity_map_enabled = true
      end

      after(:all) do
        Mongoid.identity_map_enabled = false
      end

      let!(:blog) do
        Blog.create
      end

      let!(:post_one) do
        blog.posts.create(:title => "one")
      end

      let!(:post_two) do
        blog.posts.create(:title => "two")
      end

      it "does not duplicate ids in the eager load query" do
        Blog.where(:_id => blog.id).first.posts.size.should eq(2)
        Blog.where(:_id => blog.id).first.posts.size.should eq(2)
      end
    end

    context "when using integer ids" do

      before(:all) do
        Person.identity :type => Integer
      end

      after(:all) do
        Person.identity :type => BSON::ObjectId
      end

      context "when passed a string" do

        let!(:person) do
          Person.create(:_id => 1, :ssn => "123-44-4321")
        end

        let(:from_db) do
          Person.find("1")
        end

        it "returns the matching document" do
          from_db.should eq(person)
        end
      end

      context "when passed an array of strings" do

        let!(:person) do
          Person.create(:_id => 2, :ssn => "123-44-4321")
        end

        let(:from_db) do
          Person.find([ "2" ])
        end

        it "returns the matching documents" do
          from_db.should eq([ person ])
        end
      end
    end

    context "when using string ids" do

      let!(:person) do
        Person.create(:title => "Mrs.", :ssn => "another")
      end

      let!(:documents) do
        3.times.map do |n|
          Person.create(:title => "Mr.", :ssn => "#{n}22")
        end
      end

      before(:all) do
        Person.identity :type => String
      end

      after(:all) do
        Person.identity :type => BSON::ObjectId
      end

      context "with an id as an argument" do

        context "when the document is found" do

          it "returns the document" do
            Person.find(person.id).should == person
          end
        end

        context "when the document is not found" do

          it "raises an error" do
            expect {
              Person.find(BSON::ObjectId.new.to_s)
            }.to raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end

        context "when the identity map is enabled" do

          before do
            Mongoid.identity_map_enabled = true
          end

          after do
            Mongoid.identity_map_enabled = false
          end

          context "when the document is found in the map" do

            before do
              Mongoid::IdentityMap.set(person)
            end

            let(:from_map) do
              Person.find(person.id)
            end

            it "returns the document" do
              from_map.should eq(person)
            end

            it "returns the same instance" do
              from_map.should equal(person)
            end
          end

          context "when the document is not found in the map" do

            let(:from_db) do
              Person.find(person.id)
            end

            it "returns the document from the database" do
              from_db.should eq(person)
            end

            it "returns a different instance" do
              from_db.should_not equal(person)
            end
          end
        end
      end

      context "when passed an array of ids" do

        context "when the documents are found" do

          let(:people) do
            Person.find(documents.map(&:id))
          end

          it "returns an array of the documents" do
            people.should == documents
          end
        end

        context "when no documents found" do

          it "raises an error" do
            expect {
              Person.find([
                BSON::ObjectId.new.to_s, BSON::ObjectId.new.to_s
              ])
            }.to raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end
      end

      context "when passing an empty array" do

        let(:people) do
          Person.find([])
        end

        it "returns an empty array" do
          people.should be_empty
        end
      end
    end

    context "when using object ids" do

      let!(:person) do
        Person.create(:title => "Mrs.", :ssn => "another")
      end

      let!(:documents) do
        3.times.map do |n|
          Person.create(:title => "Mr.", :ssn => "#{n}22")
        end
      end

      before(:all) do
        Person.identity :type => BSON::ObjectId
      end

      context "when passed a BSON::ObjectId as an argument" do

        context "when the document is found" do

          it "returns the document" do
            Person.find(person.id).should == person
          end
        end

        context "when the document is not found" do

          it "raises an error" do
            expect {
              Person.find(BSON::ObjectId.new)
            }.to raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end
      end

      context "when passed a string id as an argument" do

        context "when the document is found" do

          it "returns the document" do
            Person.find(person.id.to_s).should == person
          end
        end

        context "when the document is not found" do

          it "raises an error" do
            expect {
              Person.find(BSON::ObjectId.new.to_s)
            }.to raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end
      end

      context "when passed an array of ids as args" do

        context "when the documents are found" do

          let(:people) do
            Person.find(documents.map(&:id))
          end

          it "returns an array of the documents" do
            people.should == documents
          end
        end

        context "when no documents found" do

          it "raises an error" do
            expect {
              Person.find([
                BSON::ObjectId.new, BSON::ObjectId.new
              ])
            }.to raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end
      end
    end
  end

  describe ".find_or_create_by" do

    context "when the document is found" do

      let!(:person) do
        Person.create(:title => "Senior", :ssn => "333-22-1111")
      end

      it "returns the document" do
        Person.find_or_create_by(:title => "Senior").should == person
      end
    end

    context "when the document is not found" do

      context "when not providing a block" do

        let!(:person) do
          Person.find_or_create_by(:title => "Senorita", :ssn => "1234567")
        end

        it "creates a persisted document" do
          person.should be_persisted
        end

        it "sets the attributes" do
          person.title.should == "Senorita"
        end
      end

      context "when providing a block" do

        let!(:person) do
          Person.find_or_create_by(:title => "Senorita", :ssn => "1") do |person|
            person.pets = true
          end
        end

        it "creates a persisted document" do
          person.should be_persisted
        end

        it "sets the attributes" do
          person.title.should == "Senorita"
        end

        it "calls the block" do
          person.pets.should == true
        end
      end
    end
  end

  describe ".find_or_initialize_by" do

    context "when the document is found" do

      let!(:person) do
        Person.create(:title => "Senior", :ssn => "333-22-1111")
      end

      it "returns the document" do
        Person.find_or_initialize_by(:title => "Senior").should == person
      end
    end

    context "when the document is not found" do

      context "when not providing a block" do

        let!(:person) do
          Person.find_or_initialize_by(:title => "Senorita", :ssn => "1234567")
        end

        it "creates a new document" do
          person.should be_new
        end

        it "sets the attributes" do
          person.title.should == "Senorita"
        end
      end

      context "when providing a block" do

        let!(:person) do
          Person.find_or_initialize_by(:title => "Senorita", :ssn => "1") do |person|
            person.pets = true
          end
        end

        it "creates a new document" do
          person.should be_new
        end

        it "sets the attributes" do
          person.title.should == "Senorita"
        end

        it "calls the block" do
          person.pets.should == true
        end
      end
    end
  end
end
