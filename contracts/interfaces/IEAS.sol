// contracts/interfaces/IEAS.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IEAS {
    struct Attestation {
        bytes32 uid;
        bytes32 schema;
        uint64 time;
        uint64 expirationTime;
        uint64 revocationTime;
        bytes32 refUID;
        address attester;
        bytes32 recipient;
        bool revocable;
        bytes data;
    }

    function attest(bytes32 schema, bytes calldata data) external returns (bytes32);
    function revoke(bytes32 schema, bytes32 uid) external;
}