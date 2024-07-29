// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Import ReentrancyGuard from OpenZeppelin
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AutomobileDeal /* is ReentrancyGuard */ {
    address public immutable owner;
    address private seller;
    address private buyer;

    string[] public Vins;

    struct detailOfVehicle {
        // string vehicleVIN;
        string name;
        uint256 price;
        bool isSold;
        //address seller;
    }

    uint256 public feePercentage; // owner sets the fee

    mapping(string VIN => bool) public isValidVIN;
    mapping(string VIN => address seller) public isSeller;
    mapping(string VIN => bool) public isSold;
    mapping(string VIN => detailOfVehicle) public details;
    mapping(string VIN => address buyer) public isBuyer;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");

        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "You are not the seller!");

        _;
    }

    event Purchased(address indexed _buyer, uint256 _price, string _vin);
    event vinAdded(string _vin);

    constructor(uint _fee) {
        owner = msg.sender;
        feePercentage = _fee;
        //seller = msg.sender;
    }

    function addVIN(string memory _vin /* onlySeller */) public {
        require(!isValidVIN[_vin], "This vehicle is already listed!");
        isValidVIN[_vin] = true;
        isSeller[_vin] = msg.sender;
        Vins.push(_vin);

        emit vinAdded(_vin);
    }

    function listVehicle(
        string memory _vin,
        string memory _name,
        uint256 _price
    ) public {
        require(isValidVIN[_vin], "This VIN is not added.");
        require(_price > 0, "It cannot be sold at zero.");
        require(isSeller[_vin] == msg.sender, "You didn't listed this vehicle");
        details[_vin] = detailOfVehicle({
            name: _name,
            price: _price,
            isSold: false
        });
    }

    function calculateTotalPriceOfDeal(
        string memory _vin
    ) public view returns (uint) {
        uint priceOfVehicle = details[_vin].price;
        uint fee = ((priceOfVehicle * feePercentage) / 100);
        return priceOfVehicle + fee;
    }

    function purchase(string memory _vin) public payable {
        require(isValidVIN[_vin], "This vehicle is not yet listed.");
        require(!isSold[_vin], "This vehicle is already sold.");
        require(
            msg.value >= calculateTotalPriceOfDeal(_vin),
            "You need to pay the correct amount."
        );

        isBuyer[_vin] = msg.sender;
        isSold[_vin] = true;

        for (uint i = 0; i < Vins.length; i++) {
            if (
                keccak256(abi.encodePacked(Vins[i])) ==
                keccak256(abi.encodePacked(_vin))
            ) {
                Vins[i] = Vins[Vins.length - 1];
                Vins.pop();
                break;
            }
        }

        (bool sentToOwner, ) = payable(owner).call{
            value: msg.value - details[_vin].price
        }("");
        require(sentToOwner, "Failed to send transaction to the owner.");

        (bool sentToSeller, ) = payable(isSeller[_vin]).call{
            value: details[_vin].price
        }("");
        require(sentToSeller, "Failed to send transaction to the seller.");

        emit Purchased(msg.sender, details[_vin].price, _vin);
    }

    function updateDetails(string memory _vin, uint256 _price) public {
        require(
            msg.sender == isSeller[_vin],
            "You are not the seller of this Vehicle."
        );
        require(_price > 0, "Price cannot be zero!");
        details[_vin].price = _price;
        // Check if price is greater than zero
        // Update vehicleVIN and price
    }

    function getVehicleDetails(
        string memory _vin
    ) public view returns (string memory _name, uint256 _price, bool _isSold) {
        detailOfVehicle memory vehicleDetail = details[_vin];
        _name = vehicleDetail.name;
        _price = vehicleDetail.price;
        _isSold = vehicleDetail.isSold;
        return (_name, _price, _isSold);
    }

    function getVins() public view returns (string[] memory) {
        return Vins;
    }

    function getBuyer(string memory _vin) public view returns (address) {
        require(isSold[_vin], "This vehicle is not sold yet.");
        return isBuyer[_vin];
    }

    function getSoldStatus(string memory _vin) public view returns (bool) {
        bool status = details[_vin].isSold;
        return status;
    }

    function getPrice(string memory _vin) public view returns (uint256) {
        require(isValidVIN[_vin], "Vin not listed.");
        return details[_vin].price;
    }

    function getSeller(string memory _vin) public view returns (address) {
        require(isValidVIN[_vin], "Vin not listed.");
        return isSeller[_vin];
    }

    // function getSellerBalance() public view returns (uint) {
    //     // Return seller's balance
    // }

    function getContractBalance() public view onlyOwner returns (uint) {
        // Return contract's balance
        return address(this).balance;
    }

    function updateFeePercentage(uint256 _fee) public onlyOwner {
        // Return fee percentage
        feePercentage = _fee;
    }
}
