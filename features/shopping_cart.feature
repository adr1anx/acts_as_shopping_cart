Feature: Shopping Cart

  Background:
    Given a product "Apple" exists
    And a shopping cart exists

  Scenario: Cart totals
    When I add product "Apple" to cart with price "9999"
    Then the subtotal for the cart should be "9999"
    And the total for the cart should be "10824"
    And the total unique items on the cart should be "1"

  Scenario: Cart Totals when cart is empty
    Then the subtotal for the cart should be "0"
    And the total for the cart should be "0"
    And the total unique items on the cart should be "0"

  Scenario: Add a product to cart twice
    When I add product "Apple" to cart with price "9999"
    And I add product "Apple" to cart with price "9999"
    Then the subtotal for the cart should be "19998"
    Then the total for the cart should be "21648"
    And the total unique items on the cart should be "2"

  Scenario: Add a product to cart twice non-cumulatively
    When I add product "Apple" to cart with price "9999"
    And I add product "Apple" to cart with price "9999"
    And I non-cumulatively add product "Apple" to cart with price "9999"
    Then the subtotal for the cart should be "9999"
    Then the total for the cart should be "10824"
    And the total unique items on the cart should be "1"

  Scenario: Remove products from cart
    Given I add 3 "Apple" products to cart with price "9999"
    When I remove 1 "Apple" unit from cart
    Then the total unique items on the cart should be "2"
    When I remove 99 "Apple" units from cart
    Then the total unique items on the cart should be "0"
    And cart should be empty

  Scenario: Totals for a single item
    Given I add 3 "Apple" products to cart with price "9999"
    Then the subtotal for "Apple" on the cart should be "29997"
    And the quantity for "Apple" on the cart should be "3"
    And the price for "Apple" on the cart should be "9999"

  Scenario: Subtotal for a product that is not on cart
    Then the subtotal for "Apple" on the cart should be "0"

  Scenario: Update the quantity of a cart item
    Given I add 99 "Apple" products to cart with price "9999"
    When I update the "Apple" quantity to "2"
    Then the quantity for "Apple" on the cart should be "2"

  Scenario: Update the price of a cart item
    Given I add 99 "Apple" products to cart with price "9999"
    When I update the "Apple" price to "1099"
    Then the price for "Apple" on the cart should be "1099"

  Scenario: Empty the shopping cart
    Given I add 99 "Apple" products to cart with price "9999"
    When I empty the cart
    Then cart should be empty
    And the total for the cart should be "0"

  Scenario: Item should hold a relation to cart
    When I add product "Apple" to cart with price "9999"
    Then shopping cart item "Apple" should belong to cart


