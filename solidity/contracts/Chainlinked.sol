pragma solidity ^0.4.23;

import "./ChainlinkLib.sol";
import "solidity-cborutils/contracts/CBOR.sol";

interface LinkToken {
    // ERC20 interface
    function transfer(address to, uint tokens) public returns (bool success);

    // ERC677 interface
    function transferAndCall(address receiver, uint amount, bytes data) public returns (bool success);
}

interface Oracle {
    function cancel(uint256 _internalId) public;
}

contract Chainlinked {
  using ChainlinkLib for ChainlinkLib.Run;
  using CBOR for Buffer.buffer;

  uint256 constant clArgsVersion = 1;

  LinkToken internal link;
  Oracle internal oracle;
  uint256 internal requests = 1;

  function newRun(
    bytes32 _jobId,
    address _callbackAddress,
    string _callbackFunctionSignature
  ) internal pure returns (ChainlinkLib.Run memory) {
    ChainlinkLib.Run memory run;
    return run.initialize(_jobId, _callbackAddress, _callbackFunctionSignature);
  }

  function chainlinkRequest(ChainlinkLib.Run memory _run, uint256 _wei)
    internal
    returns(bytes32)
  {
    requests += 1;
    _run.externalId = keccak256(this, requests);
    _run.close();
    require(link.transferAndCall(
      oracle,
      _wei,
      _run.encodeForOracle(clArgsVersion)));

    return _run.externalId;
  }

  function LINK(uint256 _amount) internal pure returns (uint256) {
		return _amount * 10**18;
  }

  function setOracle(address _oracle) internal {
    oracle = Oracle(_oracle);
  }

  function setLinkToken(address _link) internal {
    link = LinkToken(_link);
  }

  modifier onlyOracle() {
    require(msg.sender == address(oracle));
    _;
  }
}
