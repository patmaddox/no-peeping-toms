require File.dirname(__FILE__) + '/spec_helper'

module NoPeepingTomsSpec
  class Person < ActiveRecord::Base; end
  
  class PersonObserver < ActiveRecord::Observer
    def before_update(person)
      $observer_called_names.push person.name
    end
  end
  
  class AnotherObserver < ActiveRecord::Observer
    observe Person
    def before_update(person)
      $calls_to_another_observer += 1
    end
  end
  
  describe Person, " when changing a name" do
    before(:each) do
      $observer_called_names = []
      $calls_to_another_observer = 0
      @person = Person.create! :name => "Pat Maddox"
    end

    it "should not register a name change" do
      @person.update_attribute :name, "Name change"
      $observer_called_names.pop.should be_blank
      $calls_to_another_observer.should == 0
    end

    it "should register a name change with the person observer turned on by name" do
      Person.with_observers("NoPeepingTomsSpec::PersonObserver") do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 0
    end
    
    it "should register a name change with the person observer turned on by class reference" do
      Person.with_observers(NoPeepingTomsSpec::PersonObserver) do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 0      
    end

    it "should register a name change with an anonymous observer" do
      observer = Class.new(ActiveRecord::Observer) do
        def before_update(person)
          $observer_called_names.push person.name
        end
      end
      Person.with_observers(observer) do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 0      
    end

    
    it "should handle multiple observers" do
      Person.with_observers("NoPeepingTomsSpec::PersonObserver", "NoPeepingTomsSpec::AnotherObserver") do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 1
    end

    it "should handle multiple anonymous observers" do
      observer1 = Class.new(ActiveRecord::Observer) do
        def before_update(person) ; $observer_called_names.push "#{person.name} 1" ; end
      end
      observer2 = Class.new(ActiveRecord::Observer) do
        def before_update(person) ; $observer_called_names.push "#{person.name} 2" ; end
      end

      Person.with_observers(observer1, observer2) do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change 2"
        $observer_called_names.pop.should == "Name change 1"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 0
    end
  end
end
