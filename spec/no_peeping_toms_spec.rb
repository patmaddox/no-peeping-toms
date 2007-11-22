require File.dirname(__FILE__) + '/spec_helper'

module NoPeepingTomsSpec
  class Person < ActiveRecord::Base; end
  
  class PersonObserver < ActiveRecord::Observer
    def before_update(person)
      $observer_calls.push person.name
    end
  end
  
  describe Person, " when changing a name" do
    before(:each) do
      $observer_calls = []
      @person = Person.create! :name => "Pat Maddox"
    end

    it "should not register a name change" do
      @person.update_attribute :name, "Name change"
      $observer_calls.pop.should be_blank
    end

    it "should register a name change with the person observer turned on" do
      Person.with_observers("NoPeepingTomsSpec::PersonObserver") do
        @person.update_attribute :name, "Name change"
        $observer_calls.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_calls.pop.should be_blank
    end
  end
end
