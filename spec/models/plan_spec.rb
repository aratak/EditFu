require 'spec_helper'

shared_examples_for "general plans tests" do
  
  describe "class" do
    
    before :each do
      @false_predicats = Plan.all.each.map{ |pl| :"#{pl.name.underscore}?"  } - [:"#{@plan.name.underscore}?"]
    end
    
    it "should has true predicat" do
      @plan.send("#{@plan.name.underscore}?").should be_true
    end

    it "should has true predicat" do
      @plan.send("not_#{@plan.name.underscore}?").should be_false
    end


    it "should return false" do
      @false_predicats.each do |predicat|
        @plan.send(predicat).should be_false
      end
    end

    it "should return false" do
      @false_predicats.each do |predicat|
        @plan.send("not_#{predicat}").should be_true
      end
    end

    
  end

  it "should has correct string price" do
    @plan.str_price == "$ #{@plan.price}"
  end
  
end



describe Plan do

  describe "simple checking " do
    Plan.all.each do |plan|

      before :each do
        @plan = plan
      end
      it_should_behave_like "general plans tests"

      describe "#check permissions" do
      
        it "has 'can_add_{permission}?' method" do
          Plan::ALLOWS.keys.each do |perm|
            @plan.should be_respond_to(:"can_add_#{perm}?")
          end
        end
      
      end

    end
  end
  
  
  describe "checking permissions" do

    before :each do
      @owner = mock(:Owner)
      @owner.stub(:owner?).and_return(true)
    end


    describe 'can_add_page?' do
      
      [Plan::TRIAL, Plan::UNLIMITEDTRIAL, Plan::SINGLE, Plan::PROFESSIONAL].each do |plan|
        it "for naked plan #{plan}" do
          @owner.stub(:plan).and_return(plan)
          plan.can_add_page?(@owner).should be_true
        end
      end
      
      it 'for FREE plan with 2 pages' do
        @owner.stub(:pages).and_return([1,2])
        Plan::FREE.can_add_page?(@owner).should be_true
      end

      it 'for FREE plan with 3 pages' do
        @owner.stub(:pages).and_return([1,2,3])
        Plan::FREE.can_add_page?(@owner).should be_false
      end

      it 'for FREE plan with 4 pages' do
        @owner.stub(:pages).and_return([1,2,3,4])
        Plan::FREE.can_add_page?(@owner).should be_false
      end

    end
    
    
    describe 'can_add_editor? and can_add_site?' do
    
      [Plan::TRIAL, Plan::UNLIMITEDTRIAL, Plan::PROFESSIONAL].each do |plan|
        it "allowed plans '#{plan.name}'" do
          @owner.stub(:plan).and_return(plan)
          plan.can_add_editor?(@owner).should be_true
        end

        it "allowed plans '#{plan.name}'" do
          @owner.stub(:plan).and_return(plan)
          plan.can_add_site?(@owner).should be_true
        end
      end

      [Plan::FREE, Plan::SINGLE].each do |plan|
        it "denied plans '#{plan.name}'" do
          @owner.stub(:plan).and_return(plan)
          plan.can_add_editor?(@owner).should be_false
        end

        it "denied plans '#{plan.name}'" do
          @owner.stub(:plan).and_return(plan)
          plan.can_add_site?(@owner).should be_false
        end
      end

    end
    
  end
  
  
end
