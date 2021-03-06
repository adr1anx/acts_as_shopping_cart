require File.expand_path(File.dirname(__FILE__) + '../../../../spec_helper')
# require 'spec_helper'

describe ActiveRecord::Acts::ShoppingCart::Collection do
  let(:klass) do
    klass = Class.new
    klass.send(:include, ActiveRecord::Acts::ShoppingCart::Collection)
  end

  let(:subject) do
    subject = klass.new
    subject.stub(:shopping_cart_items).and_return([])
    subject
  end

  let(:object) { stub }

  let(:shopping_cart_item) do
    stub(:quantity => 2, :save => true)
  end

  describe :add do
    context "item is not on cart" do
      before do
        subject.stub(:item_for).with(object)
      end

      it "creates a new shopping cart item" do
        subject.shopping_cart_items.should_receive(:create).with(:item => object, :price => 1999, :quantity => 3)
        subject.add(object, 1999, 3)
      end
    end

    context "item is not in cart" do
      before do
        subject.stub(:item_for).with(object)
      end

      it "creates a new shopping cart item non-cumulatively" do
        subject.shopping_cart_items.should_receive(:create).with(:item => object, :price => 1999, :quantity => 3)
        subject.add(object, 1999, 3, false)
      end
    end

    context "item is already on cart" do
      before do
        subject.stub(:item_for).with(object).and_return(shopping_cart_item)
      end

      it "updates the quantity for the item" do
        shopping_cart_item.should_receive(:quantity=).with(5)
        subject.add(object, 1999, 3)
      end
    end

    context "item is already in cart" do
      before do
        subject.stub(:item_for).with(object).and_return(shopping_cart_item)
      end

      it "updates the quantity for the item non-cumulatively" do
        shopping_cart_item.should_receive(:quantity=).with(3) # not 5
        subject.add(object, 19.99, 3, false)
      end
    end
  end

  describe :clear do
    before do
      subject.shopping_cart_items.should_receive(:clear)
    end

    it "clears all the items in the cart" do
      subject.clear
      subject.empty?.should be_true
    end
  end

  describe "empty?" do
    context "cart has items" do
      before do
        subject.shopping_cart_items << mock
      end

      it "returns false" do
        subject.empty?.should be_false
      end
    end

    context "cart is empty" do
      it "returns true" do
        subject.empty?.should be_true
      end
    end
  end

  describe :remove do
    context "item is not on cart" do
      before do
        subject.stub(:item_for).with(object)
      end

      it "does nothing" do
        subject.remove(object)
      end
    end

    context "item is on cart" do
      before do
        subject.stub(:item_for).with(object).and_return(shopping_cart_item)
      end

      context "remove less items than those on cart" do
        it "just updates the shopping cart item quantity" do
          shopping_cart_item.should_receive(:quantity=).with(1)
          subject.remove(object, 1)
        end
      end

      context "remove more items than those on cart" do
        it "removes the shopping cart item object completely" do
          shopping_cart_item.should_receive(:delete)
          subject.remove(object, 99)
        end
      end
    end
  end

  describe :subtotal do
    context "cart has no items" do
      before do
        subject.stub(:shopping_cart_items).and_return([])
      end

      it "returns 0" do
        subject.subtotal.should eq(Money.new(0))
      end
    end

    context "cart has items" do
      before do
        items = [stub(:quantity => 2, :price => 3399), stub(:quantity => 1, :price => 4599)]
        subject.stub(:shopping_cart_items).and_return(items)
      end

      it "returns the sum of the price * quantity for all items" do
        subject.subtotal.should eq(Money.new(11397))
      end
    end
  end

  describe :shipping_cost do
    it "returns 0" do
      subject.shipping_cost.should eq(Money.new(0))
    end
  end

  describe :taxes do
    context "subtotal is 100" do
      before do
        subject.stub(:subtotal).and_return(100)
      end

      it "returns 8.25" do
        subject.taxes.should eq(8.25)
      end
    end
  end

  describe :tax_pct do
    it "returns 8.25" do
      subject.tax_pct.should eq(8.25)
    end
  end

  describe :total do
    before do
      subject.stub(:subtotal).and_return(1099)
      subject.stub(:taxes).and_return(1399)
      subject.stub(:shipping_cost).and_return(1299)
    end

    it "returns subtotal + taxes + shipping_cost" do
      subject.total.should eq(Money.new(3797))
    end
  end

  describe :total_unique_items do
    context "cart has no items" do
      it "returns 0" do
        subject.total_unique_items.should eq(0)
      end
    end

    context "cart has some items" do
      before do
        items = [stub(:quantity => 2, :price => 3399), stub(:quantity => 1, :price => 4599)]
        subject.stub(:shopping_cart_items).and_return(items)
      end

      it "returns the sum of the quantities of all shopping cart items" do
        subject.total_unique_items.should eq(3)
      end
    end
  end
end
