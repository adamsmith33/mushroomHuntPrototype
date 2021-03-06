pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/utils/Strings.sol"; //For handling strings
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; //For ERC721 stuff
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol"; //For token IDs
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol"; //Console

import "./ShroomiesHelper.sol";
import "./accessoryHandling.sol";
import { Base64 } from "./libraries/Base64.sol";
import {sharedStructs} from "./libraries/sharedStructs.sol";

contract shroomies is ERC721URIStorage, Ownable {

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    Counters.Counter private accessoryIds;

    sharedStructs.shroomy[] public shrooms;
    string[] public shroomJSON;

    string[] public species;

    mapping(uint256 => string) public accessories;
    mapping (string => uint256) public speciesToID;
    mapping(string => uint256) public accessoriesToID;



    address itemsContract;
    address helperContract;
    address accessoryHandlingContract;
    
    constructor(string[] memory initialAccessories, string[] memory initialSpecies, address iContract, address hContract) ERC721("Shroomies", "SHRM") {
        console.log("It's...ALIVE!!!");

        setItemsContract(iContract);
        setHelperContract(hContract);

        uint counter = 0;

        for (uint i = 0; i <= initialAccessories.length; i++) {
            if(i > 0){
            accessoryIds.increment();
            accessories[accessoryIds.current()] = initialAccessories[counter];
            accessoriesToID[initialAccessories[counter]] = accessoryIds.current();
            counter++;
            } else {
                accessories[i] = "none";
                accessoriesToID[initialAccessories[i]] = i;
            }
        }

        for (uint i = 0; i < initialSpecies.length; i++) {
            species.push(initialSpecies[i]);
            speciesToID[initialSpecies[i]] = i;
        }


    }

    function setItemsContract(address addr) public onlyOwner{
        itemsContract = addr;
    }

    function setHelperContract(address addr) public onlyOwner{
        helperContract = addr;
    }

    function setAccessoryHandlingContract(address addr) public onlyOwner{
        accessoryHandlingContract = addr;
        IERC1155(itemsContract).setApprovalForAll(accessoryHandlingContract, true);
    }

    function mintShroomy(string memory _name) public {
        //require(balanceOf(msg.sender) == 0, "One shroom policy");
        uint256 tokenId = tokenIds.current();

        uint256 speciesId = (IShroomiesHelper(helperContract).rand(string(abi.encodePacked(_name,block.timestamp))) % (species.length-1)) + 1;
        console.log(speciesId);

        string memory img = IShroomiesHelper(helperContract).selectImage(speciesId, 0, 0);

        string memory tokenURI = IShroomiesHelper(helperContract).createTokenURI(_name, tokenId, species[speciesId], img);

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        tokenIds.increment();

        shrooms.push(sharedStructs.shroomy({
            name: _name,
            description: "A cute mushroom.",
            imageURI: img,
            mushroomNo: tokenId,
            species: species[speciesId],
            accessory: 0,
            age: 0,
            experience: 0
        }));

    }

    function changeAccessories(uint256 ID, uint256 accessoryId) public {
        require(ownerOf(ID) == msg.sender, "You don't own this shroom");
        string memory newImage = IShroomiesHelper(helperContract).selectImage(speciesToID[shrooms[ID].species], shrooms[ID].age, accessoryId);

        IaccessoryHandling(accessoryHandlingContract).AccessoryChange(ID, accessoryId, msg.sender);

        string memory updatedURI = IaccessoryHandling(accessoryHandlingContract).updateURI(shrooms[ID].name, shrooms[ID].description, newImage, shrooms[ID].mushroomNo, shrooms[ID].species, accessories[accessoryId], shrooms[ID].age, shrooms[ID].experience);

        shrooms[ID].accessory = accessoryId;
        shrooms[ID].imageURI = newImage;
        _setTokenURI(ID, updatedURI);
    }

    function ageShroom(uint256 ID) public {
        uint256 newAge = shrooms[ID].age + 1;

        string memory newImage = IShroomiesHelper(helperContract).selectImage(speciesToID[shrooms[ID].species], newAge, shrooms[ID].accessory);

        string memory ageURI = IaccessoryHandling(accessoryHandlingContract).updateURI(shrooms[ID].name, shrooms[ID].description, newImage, shrooms[ID].mushroomNo, shrooms[ID].species, accessories[shrooms[ID].accessory], newAge, shrooms[ID].experience);

        shrooms[ID].age += 1;
        shrooms[ID].imageURI = newImage;
        _setTokenURI(ID, ageURI);
    }

    function getShroomy(uint256 _tokenId) public view returns(sharedStructs.shroomy memory) {
        sharedStructs.shroomy memory selectedShroom = shrooms[_tokenId];
        return selectedShroom;
    }

    function getAllShrooms() public view returns(sharedStructs.shroomy[] memory){
        return shrooms;
    }

    function getYourShroomy() public view returns(sharedStructs.shroomy memory) {
        sharedStructs.shroomy memory shroom;
        for(uint i=0; i<shrooms.length; i++) {
            if(ownerOf(i) == msg.sender){
                shroom = shrooms[i];
            }
        }

        return shroom;
    }

    function currentAccessory(uint256 ID) public view returns(uint256){
        return shrooms[ID].accessory;
    }

}



interface Ishroomies {

    function currentAccessory(uint256 ID) external view returns(uint256);

    function getShroomy(uint256 _tokenId) external view returns(sharedStructs.shroomy memory);

    function getAllShrooms() external view returns(sharedStructs.shroomy[] memory);

}