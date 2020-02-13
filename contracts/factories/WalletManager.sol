pragma solidity ^0.5.13;

import "./MultiSigWallet.sol";
import "../modules/Manageable.sol";
import "../modules/iFactory.sol";

/// @title WalletManager
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.3.0
/// @notice This module allows for managing multisig wallets.
// prettier-ignore
contract WalletManager is Manageable {

    address private _walletFactory;

    function getWalletFactory() public view returns (address walletFactory) {
        return _walletFactory;
    }
    
    function _getInitCalldata() public view returns (bytes memory initCalldata) {
        address[] memory adds = new address[](1);
        adds[0] = address(this);
        return abi.encodeWithSelector(
            iFactory(_walletFactory).getInitSelector(),
            adds, // _owners
            1  // _required
        );
    }

    constructor(address walletFactory) public {
        _walletFactory = walletFactory;
    }

    /// @dev Allows to create a new wallet.
    /// @return instance address of the clone that was created.
    function create() public onlyManagerOrOwner() returns (address wallet) {
        return iFactory(_walletFactory).create(_getInitCalldata());
    }

    /// @dev Allows to create a new wallet.
    /// @param salt bytes32 unique salt for deterministic address generation
    /// @return instance address of the clone that was created.
    function createSalty(bytes32 salt) public onlyManagerOrOwner() returns (address wallet) {
        return iFactory(_walletFactory).createSalty(_getInitCalldata(), salt);
    }

    function getNextNonceInstance() public view returns (address instance) {
        return iFactory(_walletFactory).getNextNonceInstance(address(this), _getInitCalldata());
    }

    function getSaltyInstance(bytes32 salt) public view returns (address instance, bool validity) {
        return iFactory(_walletFactory).getSaltyInstance(address(this), _getInitCalldata(), salt);
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param wallet Address of wallet.
    /// @param owner Address of new owner.
    function addOwner(address payable wallet, address owner) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).addOwner(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param wallet Address of wallet.
    /// @param owner Address of owner.
    function removeOwner(address payable wallet, address owner) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).removeOwner(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param wallet Address of wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address payable wallet, address owner, address newOwner) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).replaceOwner(owner, newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param wallet Address of wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(address payable wallet, uint256 _required) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).changeRequirement(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param wallet Address of wallet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(
        address payable wallet,
        address destination,
        uint256 value,
        bytes memory data
    ) public onlyManagerOrOwner() returns (uint256 transactionId) {
        return MultiSigWallet(wallet).submitTransaction(destination, value, data);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    function confirmTransaction(address payable wallet, uint256 transactionId) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(address payable wallet, uint256 transactionId) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).revokeConfirmation(transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    function executeTransaction(address payable wallet, uint256 transactionId) public onlyManagerOrOwner() {
        MultiSigWallet(wallet).executeTransaction(transactionId);
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(address payable wallet, uint256 transactionId) public view returns (bool) {
        return MultiSigWallet(wallet).isConfirmed(transactionId);
    }

    /// @dev Returns number of confirmations of a transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(address payable wallet, uint256 transactionId) public view returns (uint256 count) {
        return MultiSigWallet(wallet).getConfirmationCount(transactionId);
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param wallet Address of wallet.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(address payable wallet, bool pending, bool executed) public view returns (uint256 count) {
        return MultiSigWallet(wallet).getTransactionCount(pending, executed);
    }

    /// @dev Returns list of owners.
    /// @param wallet Address of wallet.
    /// @return List of owner addresses.
    function getOwners(address payable wallet) public view returns (address[] memory) {
        return MultiSigWallet(wallet).getOwners();
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param wallet Address of wallet.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(address payable wallet, uint256 transactionId) public view returns (address[] memory _confirmations) {
        return MultiSigWallet(wallet).getConfirmations(transactionId);
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param wallet Address of wallet.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(
        address payable wallet,
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) public view returns (uint256[] memory _transactionIds) {
        return MultiSigWallet(wallet).getTransactionIds(from, to, pending, executed);
    }
}
