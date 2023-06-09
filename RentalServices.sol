// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RentalServices {

using SafeMath for uint256;

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

  // Details of a particular booking
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

  /**
   * @dev Put up a property in the market
   * @param name Name of the property
   * @param description Short description of your property
   * @param price Price per day 
   */
  function rentOutproperty(string memory name, string memory description, uint256 price) public {
    Property memory property = Property(name, description, true /* isActive */, price, msg.sender /* owner */, new bool[](365));

    // Persist `property` object to the "permanent" storage
    properties[propertyId++] = property;

    // emit an event to notify the clients
    emit NewProperty(propertyId++);
  }

  /**
   * @dev Make a booking
   * @param _propertyId id of the property to rent out
   * @param checkInDate Check-in date
   * @param checkoutDate Check-out date
   */
  function rentProperty(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) public payable {
    // Retrieve `property` object from the storage
    Property storage property = properties[_propertyId];

    // Check that property ID is valid
    require(property.owner != address(0), "Invalid property ID");

    // Check that property is active
    require(property.isActive == true, "Property with this ID is not active");

    // Check that checkInDate is before checkoutDate
    require(checkInDate < checkoutDate, "Invalid date range");

    // check that property is active
    require(
      property.isActive == true,
      "property with this ID is not active"
    );

    // Check the availability of the property for the specified dates
    uint256[] memory bookedDates;
    uint256 bookedDatesCount = 0;
    for (uint256 i = checkInDate; i <= checkoutDate; i++) {
      if (property.isBooked[i] == true) {
        // Property is already booked on this date, store the booked date
        bookedDates[bookedDatesCount] = i;
        bookedDatesCount++;
      }
    }

    // If any dates are already booked, revert the transaction with the booked dates
      if (bookedDatesCount > 0) {
      string memory errorMessage = string(abi.encodePacked("Property is not available for the following dates: "));
      for (uint256 i = 0; i < bookedDatesCount; i++) {
      errorMessage = string(abi.encodePacked(errorMessage, uint2str(bookedDates[i])));
      if (i < bookedDatesCount - 1) {
        errorMessage = string(abi.encodePacked(errorMessage, ", "));
       }
      }
      revert(errorMessage);
      }

    // Calculate the total booking price using SafeMath
    uint256 numberOfDays = checkoutDate.sub(checkInDate);
    uint256 totalPrice = property.price.mul(numberOfDays);
     
    // Check the customer has sent an amount equal to (pricePerDay * numberOfDays)
    require(
      msg.value == totalPrice * (checkoutDate - checkInDate),
      "Sent insufficient funds"
    );

    // send funds to the owner of the property
    _sendFunds(property.owner, msg.value);

    // conditions for a booking are satisfied, so make the booking
    _createBooking(_propertyId, checkInDate, checkoutDate);
  }

  // Helper function to convert uint to string
  function uint2str(uint256 _i) internal pure returns (string memory) {
    if (_i == 0) {
        return "0";
          }
     uint256 j = _i;
    uint256 length;
    while (j != 0) {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    while (_i != 0) {
    k = k - 1;
    uint256 remainder = _i % 10;
    _i /= 10;
    bstr[k] = bytes1(uint8(48 + remainder));
    }
    return string(bstr);
    }

  function _createBooking(uint256 _propertyId, uint256 checkInDate, uint256 checkoutDate) internal {

    // Increment the booking ID before assigning it
    bookingId++;

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

  function _sendFunds (address propertyOwner, uint256 value) internal {
    payable(propertyOwner).transfer(value);
  }

  /**
   * @dev Take down the property from the market
   * @param _propertyId Property ID
   */
  function markPropertyAsInactive(uint256 _propertyId) public {
    require(
      properties[_propertyId].owner == msg.sender,
      "THIS IS NOT YOUR PROPERTY"
    );
    properties[_propertyId].isActive = false;
  }
}



  




