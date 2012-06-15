require 'spec_helper'

describe Spree::LineItem do

  it { should have_many(:option_values).through(:line_item_option_values) }

  let(:option_type)  { mock_model(Spree::OptionType, :name => 'shoe-color', :presentation => 'Color') }
  let(:option_value) { mock_model(Spree::OptionValue, :name => 'fred', :presentation => 'Fire Engine Red', :option_type => option_type, :adder => 2.0) }
  let(:variant)      { mock_model(Spree::Variant, :price => 66.99) }
  let(:line_item)    { Spree::LineItem.new :quantity => 1 }
  let(:order)        { Factory.build :order }

  before do
    line_item.stub(:variant => variant, :order => order)
  end

  context "line_item.options" do

    it "should return true for has_options?" do
      line_item.option_values << option_value
      line_item.has_options?.should be_true
    end

    it "should save copies of option_value.name/presentation to join table" do
      line_item.option_values << option_value
      line_item.save
      line_item.options.first.adder.should == option_value.adder
      line_item.options.first.type_name.should == option_type.name
      line_item.options.first.type_presentation.should == option_type.presentation
      line_item.options.first.value_name.should == option_value.name
      line_item.options.first.value_presentation.should == option_value.presentation
      #line_item.options.first.customization.should == option_value.adder
    end

  end

  context "#price" do
    it "should include the options adders when pricing" do
      line_item.stub :option_values => [option_value]
      option_value.should_receive :adder
      line_item.valid?
      line_item.price.to_f.should == 68.99
    end
  end

end
