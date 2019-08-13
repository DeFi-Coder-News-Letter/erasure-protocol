pragma solidity ^0.5.0;

import "./iFactory.sol";


contract Template {

    address private _factory;

    // state functions

    constructor() public {
        _factory = msg.sender;
    }

    // modifiers

    modifier onlyConstructorDelegateCall() {
        // only allow function to be delegatecalled from within a constructor.
        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    // view functions

    function getCreator() public view returns (address creator) {
        creator = iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) public view returns (bool ok) {
        ok = (caller == getCreator());
    }

}