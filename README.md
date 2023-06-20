# How to Build a Rental Service Smart Contract on Celo Blockchain Network:

## Introduction:

In this tutorial, you will build a Rental Service Smart Contract on the [Celo](https://celo.org/) blockchain network. This will enable users to spend Celo on transactions.

A rental service is a business that provides customers or users the ability to temporarily use a good or service for a fee. The rental service can apply to a wide range of products including vehicles, equipment, appliances etc.

Rental services have become popular because they offer individuals and businesses a flexible way to access and use various items without incurring the full cost of ownership. This flexibility allows customers or users to use a product when they need it, without the burdensome responsibility of maintenance, storage and repairs.

Overall, rental services have proven to be a helpful solution for many people seeking to use temporary goods or services.

Examples of rental services companies include [Airbnb](https://www.airbnb.com/), [Enterprise Rent-A-Car](https://www.enterprise.com/en/home.html), [Zipcar](https://www.zipcar.com/) among many others.

## Table of Contents:

- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Requirements](#requirements)
- [Building our Smart Contract](#building-our-smart-contract)
- [Create Data Structures](#create-data-structures)
- [Define Events](#define-events)
- [Smart Contract Functions](#smart-contract-functions)
    - [rentOutProperty Function](#rentoutproperty-function)
    - [rentProperty Function](#rentproperty-function)
    - [createBooking Function](#_createbooking-function)
    - [sendFund Function](#_sendfund-function)
    - [MarkPropropertyAsInactive Function](#_markpropropertyasinactive-function)
- (Entire Code)[#entire-code]
- [Full Smart Contract](#full-smart-contract)
- [Test Smart Contract](#test-smart-contract)
- [Conclusion](#conclusion)

## Pre-requisites:

To get the most out of this tutorial a proper understanding of the following is required:

1. [Blockcahin technology](https://dacade.org/communities/blockchain/courses/intro-to-blockchain/learning-modules/905c0ff7-7199-445d-b17e-ac0bc39ffa78)
       
2. [Solidity programming language](https://soliditylang.org/)
    
## Requirements:

To get started you need the following tools installed:

1. [Chromium-based browser](https://www.google.com/chrome/)
    
2. [Metamask extension wallet](https://metamask.io/download/)
    
3. [Celo extension wallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh)
    
4. [Remix IDE](https://remix.ethereum.org/).
   
5. Good internet connection.

## Building our Smart Contract:

In this section, we will build the Smart Contract for our application.

### Create a Solidity File:

Before you start building your Smart Contract:

1. Navigate to [Remix IDE](https://remix.ethereum.org/).
    
2. Create a new File.
    
3. Name it `RentalServices.sol`
    
If you don't know how to create a file in Remix IDE, follow this [link](https://remix-ide.readthedocs.io/en/latest/file_explorer.html#creating-new-files).

### Create Data Structures:

For this tutorial, you will create two data structures(Struct):

1. **Property Struct**: This will hold information about the property on rent.
    
2. **Booking Struct**: This will hold information about booked properties.
    
Add the code below to `RentalServices.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract RentalServices {

  // struct for Property to be rented out
  struct Property {
    string name;
    string description;
    bool isActive; // is property active
    uint256 price; // per day price 
    address owner; // property owner
    bool[] isBooked;
    // Is the property booked on a particular day,
    // For the sake of simplicity, we assign 0 to Jan 1, 1 to Jan 2 and so on
    // so isBooked[31] will denote whether the property is booked for Feb 1
  }

  uint256 public propertyId;

  // mapping of propertyId to Property object
  mapping(uint256 => Property) public properties;
```

At the top of our code, we have the following:

1. `// SPDX-License-Identifier: MIT`: This is a special type of comment in Solidity that indicates the software license that the Smart Contract is released under. In our code, we specified the `MIT` license,
    
2. `pragma solidity >=0.8.0 <0.9.0`: This is a compiler directive that tells the Solidity compiler which version of the language to use. In this case, we specified that the contract should be compiled using a version of Solidity that is greater than or equal to `0.8.0` and less than `0.9.0`.
    
3. `contract RentalServices`: The contract keyword declares a contract under which our code is encapsulated.
    
Next, we declared `struct Property` with some properties:

1. `string name`: This is the name of the property to be rented out.
    
2. `string description`: This gives a description of the property.
    
3. `bool isActive`: A flag that denotes if the property is active or not.
    
4. `uint256 price` : This is the price per day to rent the property.
    
5. `address owner` : The Celo address of the person who owns the property.
    
6. `bool[] isBooked`: This is an array of boolean values that denote whether the property is booked or not on a particular day.
    
Next, we declared some state variables:

1. `uint256 public propertyId`: This is a public variable of type `uint256` that will hold the unique identifier for each property.
    
2. `mapping(uint256 => Property) public properties`: This is a mapping that will store the information about each rental property using its unique `propertyId` as the key.
    
Now, we need to create a Bookings struct. Add the code below to your existing code.

```solidity
 struct Booking {
    uint256 propertyId;
    uint256 checkInDate;
    uint256 checkoutDate;
    address user;
  }

  uint256 public bookingId;

  // mapping of bookingId to Booking object
  mapping(uint256 => Booking) public bookings;
```

The code above declares a new struct called `Booking` that has four variables:

1. `uint256 propertyId`: This specifies a unique ID that identifies the property being booked.
    
2. `uint256 checkInDate`: This specifies the booking start date.
    
3. `uint256 checkoutDate`: This specifies the date booking end date.
    
4. `address user`: The address of the user who booked the property.
    
Next, we declared some state variables:

1. `uint256 public bookingId`: This is a public variable of type `uint256` that will hold the unique identifier for each booking.
    
2. `mapping(uint256 => Booking) public bookings`: This is a mapping that will store the information about each booking using its unique `bookingId` as the key.
    
### Define Events:

Next, we will create some events. Add the code below to `RentalServices.sol`.

```solidity
// This event is emitted when a new property is put up for sale
  event NewProperty (
    uint256 indexed propertyId
  );

  // This event is emitted when a NewBooking is made
  event NewBooking (
    uint256 indexed propertyId,
    uint256 indexed bookingId
  );
```

1. `event NewProperty`: This event is emitted when a new property is put up for sale.
    
2. `event NewBooking`: This event is emitted when a NewBooking is made.
    
### Smart Contract Functions:

In this section, we will write some functions that are required to build our rental services Smart Contract.

#### `rentOutProperty` Function:

This is the first function you will add to your Smart Contract.

```solidity
function rentOutproperty(string memory name, string memory description, uint256 price) public {
    Property memory property = Property(name, description, true /* isActive */, price, msg.sender /* owner */, new bool[](365));

    // Persist `property` object to the "permanent" storage
    properties[propertyId] = property;

    // emit an event to notify the clients
    emit NewProperty(propertyId++);
  }
```

The `rentOutProperty` function allows users to list their property for rent on our Smart Contract. Below is a detailed explanation of the function:

1. The `rentOutProperty` function takes 3 parameters that describe the property. The `name` and `description` as strings, and the rental `price` as an unsigned integer.
    
2. A `Property` struct is created with the provided parameters, along with a set of boolean values to show availability on each day of the year.
    
3. The struct is stored in a mapping called `properties` with `propertyId` as its key.
    
4. The function emits an event `NewProperty`.
    
5. The `propertyId` variable is incremented to be assigned to the next property added to the database.
    
#### `rentProperty` Function:

Add the code below to your Smart Contract.

```solidity
function rentProperty(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) public payable {
    // Retrieve `property` object from the storage
    Property storage property = properties[_propertyId];

    // check that property is active
    require(
      property.isActive == true,
      "property with this ID is not active"
    );

    // check that property is available for the dates
    for (uint256 i = checkInDate; i < checkoutDate; i++) {
      if (property.isBooked[i] == true) {
        // if property is booked on a day, revert the transaction
        revert("property is not available for the selected dates");
      }
    }

    // Check the customer has sent an amount equal to (pricePerDay * numberOfDays)
    require(
      msg.value == property.price * (checkoutDate - checkInDate) * 1e18,
      "Sent insufficient funds"
    );

    // send funds to the owner of the property
    _sendFunds(property.owner, msg.value);

    // conditions for a booking are satisfied, so make the booking
    _createBooking(_propertyId, checkInDate, checkoutDate);
  }
```

The `rentProperty` function allows users to rent listed properties on our smart contract. Below is a detailed explanation of the function:

1. The `rentProperty` function allows a user to rent a specific property by passing the `propertyId`, the `checkInDate`, and the `checkOutDate`.
    
2. The function retrieves the `Property` struct from the storage using the provided `propertyId`.
    
3. The function checks if the property is active by checking the `property.isActive` value.
    
4. The `rentProperty` function checks if the property is available for the specified dates by checking the `property.isBooked` value for each day between `checkInDate` and `checkOutDate`. If the property is booked on any day, the transaction reverts.
    
5. The `rentProperty` function requires that the user has sent the right amount for the duration of renting the property.
    
6. If the payment transaction is successful,l `_sendFunds` function is called.
    
* Finally, if all conditions are met, `_createBooking` function is called.
    
#### `_createBooking` Function:

Add the code below to your Smart Contract.

```solidity
function _createBooking(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) internal {
    // Create a new booking object
    bookings[bookingId] = Booking(_propertyId, checkInDate, checkoutDate, msg.sender);

    // Retrieve `property` object from the storage
    Property storage property = properties[_propertyId];

    // Mark the property booked on the requested dates
    for (uint256 i = checkInDate; i < checkoutDate; i++) {
      property.isBooked[i] = true;
    }

    // Emit an event to notify clients
    emit NewBooking(_propertyId, bookingId++);
  }
```

This code above defines `_createBooking` function, which takes in three parameters- `_propertyId`, `checkInDate`, and `checkoutDate`. Below is a detailed explanation of the function:

1. `bookings[bookingId] = Booking(_propertyId, checkInDate, checkoutDate, msg.sender)`: This creates a new `Booking` struct with the struct variables `_propertyId`, `checkInDate`, `checkoutDate`, and `msg.sender` and maps it in the `bookings` mapping at the index of `bookingId`.
    
2. `Property storage property = properties[_propertyId]`:This retrieves the `Property` struct corresponding to the passed `_propertyId` from the storage and assigns it to the local variable `property`.
    
3. `for (uint256 i = checkInDate; i < checkoutDate; i++) { property.isBooked[i] = true`: This loops through the dates from `checkInDate` to `checkoutDate`. For each date within the range, it sets the corresponding `isBooked` value at `property.isBooked[i]` to `true`. This marks the property as booked for the dates within that range.
    
#### `_sendFund` Function:

Add the code below to your Smart Contract:

```solidity
function _sendFunds (address propertyOwner, uint256 value) internal {
    payable(propertyOwner).transfer(value);
  }
```

This code above defines a `_sendFunds` function, which takes in two parameters - `propertyOwner` of type `address`, and `value` of type `uint256`.

`payable(propertyOwner).transfer(value)` :This transfers the specified `value` of Celo to the `propertyOwner` address.

#### `_MarkPropropertyAsInactive` Function:

Add the code below to your Smart Contract:

```solidity
function markPropertyAsInactive(uint256 _propertyId) public {
    require(
      properties[_propertyId].owner == msg.sender,
      "THIS IS NOT YOUR PROPERTY"
    );
    properties[_propertyId].isActive = false;
  }
}
```

This code above defines a function called `markPropertyAsInactive` that takes in one parameter, `_propertyId`. Below is a detailed explanation of the function:

1. `require(properties[_propertyId].owner == msg.sender, "THIS IS NOT YOUR PROPERTY")`: This checks whether `msg.sender` (i.e., the caller of the function) is the owner of the specified property. If the caller is not the owner, the function will throw an error message.
    
2. `properties[_propertyId].isActive = false`: This sets the owner's property `isActive` to `false`, effectively making it inactive.

### Entire code:

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract RentalServices {

  // struct for Property to be rented out
  struct Property {
    string name;
    string description;
    bool isActive; // is property active
    uint256 price; // per day price 
    address owner; // property owner
    bool[] isBooked;
    // Is the property booked on a particular day,
    // For the sake of simplicity, we assign 0 to Jan 1, 1 to Jan 2 and so on
    // so isBooked[31] will denote whether the property is booked for Feb 1
  }

  uint256 public propertyId;

  // mapping of propertyId to Property object
  mapping(uint256 => Property) public properties;

  struct Booking {
    uint256 propertyId;
    uint256 checkInDate;
    uint256 checkoutDate;
    address user;
  }

  uint256 public bookingId;

  // mapping of bookingId to Booking object
  mapping(uint256 => Booking) public bookings;

  // This event is emitted when a new property is put up for sale
  event NewProperty (
    uint256 indexed propertyId
  );

  // This event is emitted when a NewBooking is made
  event NewBooking (
    uint256 indexed propertyId,
    uint256 indexed bookingId
  );

  function rentOutproperty(string memory name, string memory description, uint256 price) public {
    // Create a new Property object
    Property memory property = Property(name, description, true /* isActive */, price, msg.sender /* owner */, new bool[](365));

    // Persist `property` object to the "permanent" storage
    properties[propertyId] = property;

    // emit an event to notify the clients
    emit NewProperty(propertyId++);
  }

  function rentProperty(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) public payable {
    // Retrieve `property` object from the storage
    Property storage property = properties[_propertyId];

    // check that property is active
    require(property.isActive == true, "Property with this ID is not active");

    // check that property is available for the dates
    for (uint256 i = checkInDate; i < checkoutDate; i++) {
      require(property.isBooked[i] == false, "Property is not available for the selected dates");
    }

    // Check the customer has sent an amount equal to (pricePerDay * numberOfDays)
    uint256 totalPrice = property.price * (checkoutDate - checkInDate);
    require(msg.value == totalPrice, "Sent insufficient funds");

    // send funds to the owner of the property
    _sendFunds(property.owner, msg.value);

    // conditions for a booking are satisfied, so make the booking
    _createBooking(_propertyId, checkInDate, checkoutDate);
  }

  function _createBooking(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) internal {
    // Create a new booking object
    bookings[bookingId] = Booking(_propertyId, checkInDate, checkoutDate, msg.sender);

    // Retrieve `property` object from the storage
    Property storage property = properties[_propertyId];

    // Mark the property booked on the requested dates
    for (uint256 i = checkInDate; i < checkoutDate; i++) {
      property.isBooked[i] = true;
    }

    // Emit an event to notify clients
    emit NewBooking(_propertyId, bookingId++);
  }

  function _sendFunds(address propertyOwner, uint256 value) internal {
    // Send funds to the property owner
    (bool success, ) = payable(propertyOwner).call{value: value}("");
    require(success, "Failed to send funds");
  }

  function markPropertyAsInactive(uint256 _propertyId) public {
    // Check if the property belongs to the caller
    require(properties[_propertyId].owner == msg.sender, "This is not your property");

    // Mark the property as inactive
    properties[_propertyId].isActive = false;
  }
}
    
## Test Smart Contract:

Before we can test our Smart Contract, we need to [compile and deploy](https://docs.celo.org/developer/deploy/remix) it. when you are done compiling and deploying your smart contract, test some of the functions and variables

In deploy and run transactions tabs:

1. Navigate to deployed contracts section, you will see your smart contract there
    
2. Expand your contracts. You will see buttons for functions and state variables
    
### Test `rentOutProperty` Function:

Follow the steps below to test the `rentOutProperty` function:

1. Expand the input fields next to the **rentOutProperty** button.
    
2. Enter the appropriate parameter in the **input field** provided.
    
3. Click on the **transact** button.
    
4. Confirm transaction in metamask wallet.
    
You can refer to the image below:

<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/rent-out-property.png" height="500">

### Test `rentProperty` Function:

Follow the steps below to test the `rentProperty` function:

1. Expand the input fields next to the **rentProperty** button.
    
2. Enter the appropriate parameter in the **input field** provided.
    
3. Navigate to the value field. Enter an amount corresponding to the **difference** between `checkOutDate` and `CheckInDate`.
<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/value.png" height="500">
    
4. Click on the **transact** button.
    
5. Confirm transaction in metamask wallet.
    
You can refer to the image below:

<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/rent-property.png" height="500">

### Test `bookings` Mapping:

Follow the steps below to test the `bookings` mapping:

1. Expand the input fields next to the **bookings** button.
    
2. Enter the appropriate parameter in the **input field** provided.
    
3. Click on the **call** button.
    
You can refer to the image below:

<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/bookings.png" height="500">

### Test `properties` Mapping:

Follow the steps below to test the `properties` mapping:

1. Expand the input fields next to the **bookings** button.
    
2. Enter the appropriate parameter in the **input field** provided.
    
3. Click on the **call** button.
    
You can refer to the image below:

<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/properties.png" height="500">

### Test `markPropertyAsInactive` Function:

Follow the steps below to test the `markPropertyAsInactive` function:

1. Expand the input fields next to the **markPropertyAsInactive** button.
    
2. Enter the appropriate parameter in the **input field** provided.
    
3. Click on the **transact** button.
    
4. Confirm transaction in metamask wallet.
    
You can refer to the image below:

<img src="https://github.com/segzyI/celo-Tutorial-101/blob/main/rent/active.png" alt="" height="500">

## Conclusion:

Hence, we learned how to build a Rentals Service Smart Contract on the Celo blockchain network. You can improve the functionalities or build an interactive user interface for the Smart Contract.

The complete code is available on [github](https://github.com/segzyI/celo-Tutorial-101/blob/main/RentalServices.sol).
