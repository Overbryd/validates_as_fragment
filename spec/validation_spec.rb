require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ValidatesAsFragment::Validation do
  
  before :each do
    @required_attributes = {:email => "test@model.org", :password => "pass"}
  end

  describe "fragment indicator" do

    before :each do
      @model = Model.new(@required_attributes)
    end

    describe "on a complete record" do

      before :each do
        @model.attributes = {:first_name => "Test", :last_name => "User", :date_of_birth => Date.today}
      end

      it "should be false after validation" do
        @model.valid?
        @model.should_not be_incomplete
      end

      it "should be false after save" do
        @model.save!
        @model.should_not be_incomplete
        @model.reload.should_not be_incomplete
      end
      
      it "should be false when becoming a fragment" do
        @model.save!
        @model.first_name = nil
        @model.save_fragment!
        @model.reload.should be_incomplete
      end
    end
    
    describe "on a fragment" do

      it "should be true after validation" do
        @model.valid_fragment?
        @model.should be_incomplete
      end

      it "should be true after save" do
        @model.save_fragment!
        @model.should be_incomplete
        @model.reload.should be_incomplete
      end
    end    
  end
    
  describe "valid fragment" do
    
    before :each do
      @valid_attributes = @required_attributes.merge(:password => "pass")
      @model = Model.new(@valid_attributes)
    end

    after :each do
      @model.should be_incomplete
    end
    
    it "should be valid" do
      @model.should be_valid_fragment(:email, :password)
    end
    
    it "should save given an array of attributes" do
      @model.save_fragment(:email, :password).should be_true
    end

    it "should save! given an array of attributes" do
      @model.save_fragment!(:email, :password).should be_true
    end
    
    it "should save given an attribute hash" do
      @model.save_fragment(@valid_attributes).should be_true
    end
    
    it "should save! given an attribute hash" do
      @model.save_fragment!(@valid_attributes).should be_true
    end
    
    it "should update" do
      @model.update_fragment(@valid_attributes).should be_true
    end

    it "should update!" do
      @model.update_fragment!(@valid_attributes).should be_true
    end

    it "should handle multi parameter attributes" do
      @invalid_attributes = @required_attributes.merge(
        :"date_of_birth(1i)" => "2001", :"date_of_birth(2i)" => "9", :"date_of_birth(3i)" => "11")
      @model.update_fragment(@invalid_attributes).should be_true
    end
  end

  describe "invalid fragment" do
    
    before :each do
      @invalid_attributes = @required_attributes.merge(:email => "fail")
      @model = Model.new(@invalid_attributes)
    end
    
    after :each do
      @model.should have(1).error_on(:email)
      @model.should be_new_record
      @model.should be_incomplete
    end
    
    it "should not be valid" do
      @model.should_not be_valid_fragment(:email, :password)
    end
    
    it "should not save" do
      @model.save_fragment(:email, :password).should_not be_true
    end

    it "should not save!" do
      lambda{ @model.save_fragment!(:email, :password) }.should raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should not update" do
      @model.update_fragment(@invalid_attributes).should_not be_true
    end

    it "should not update!" do
      lambda{ @model.update_fragment!(@invalid_attributes) }.should raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should handle multi parameter attributes" do
      @invalid_attributes = @invalid_attributes.merge(
        :"date_of_birth(1i)" => "", :"date_of_birth(2i)" => "", :"date_of_birth(3i)" => "")
      @model.update_fragment(@invalid_attributes).should_not be_true
      @model.should have(1).error_on(:date_of_birth)
    end
  end
end