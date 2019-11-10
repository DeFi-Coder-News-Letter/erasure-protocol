pragma solidity ^0.5.0;

import "../helpers/openzeppelin-solidity/math/SafeMath.sol";

/// @title Deadline
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract Deadline {

    using SafeMath for uint256;

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);

    // state functions

    function _setDeadline(uint256 deadline) internal {
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    // view functions

    function getDeadline() public view returns (uint256 deadline) {
        return _deadline;
    }

    // timeRemaining will default to 0 if _setDeadline is not called
    // if the now exceeds deadline, just return 0 as the timeRemaining
    function getTimeRemaining() public view returns (uint256 time) {
        if (Deadline.getDeadline() > now)
            return Deadline.getDeadline().sub(now);
        else
            return 0;
    }

    enum DeadlineStatus { isNull, isSet, isOver }
    /// Return the status of the deadline state machine
    /// - isNull: the deadline has not been set
    /// - isSet: the deadline is set, but has not passed
    /// - isOver: the deadline has passed
    function getDeadlineStatus() public view returns (DeadlineStatus status) {
        if (Deadline.getDeadline() == 0)
            return DeadlineStatus.isNull;
        if (Deadline.getDeadline() > now)
            return DeadlineStatus.isSet;
        else
            return DeadlineStatus.isOver;
    }

    function isNull() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isNull;
    }

    function isSet() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isSet;
    }

    function isOver() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isOver;
    }

}
