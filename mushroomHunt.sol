pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/utils/Counters.sol"; //For token IDs
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol"; //Console

import {sharedStructs} from "./libraries/sharedStructs.sol";

contract mushroomHunt is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private locationIds;

    sharedStructs.mycolocation[] public mycolocations;

    mapping(uint256 => sharedStructs.truffleEntry[]) public truffleBoxes;

    mapping(address => mapping(uint256 => bool)) public hasVisited;

    mapping(address => uint256[]) public userVisited;

    constructor() {

    }

    function addLocation(string memory title, string memory description, string memory imageURI, uint256 xCoord, uint256 yCoord, uint256[] memory requiredAccessories, uint256 xpValue) public onlyOwner {     
        mycolocations.push(sharedStructs.mycolocation({
            title: title,
            description: description,
            imageURI: imageURI,
            locationNo: locationIds.current(),
            xCoord: xCoord,
            yCoord: yCoord,
            requiredAccessories: requiredAccessories,
            xpValue: xpValue
        }));
        locationIds.increment();
    }

    function getMycolocation(uint256 locationId) public view returns(sharedStructs.mycolocation memory) {
        return mycolocations[locationId];
    }

    function getAllLocations() public view returns(sharedStructs.mycolocation[] memory) {
        return mycolocations;
    }

    function getTruffleBox(uint256 LocationId) public view returns(sharedStructs.truffleEntry[] memory){
        return truffleBoxes[LocationId];
    }

    function addToTruffleBox(uint256 locationId, uint256 shroomId, string memory message) public {
        truffleBoxes[locationId].push(sharedStructs.truffleEntry({
            visitor: msg.sender,
            shroomId: shroomId,
            timestamp: block.timestamp,
            message: message
        }));
    }

}

interface ImushroomHunt {
    function getMycolocation(uint256 locationId) external view returns(sharedStructs.mycolocation memory);

    function getAllLocations() external view returns(sharedStructs.mycolocation[] memory);

    function getTruffleBox(uint256 LocationId) external view returns(sharedStructs.truffleEntry[] memory);
}