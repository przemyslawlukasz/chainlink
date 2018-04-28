pragma solidity ^0.4.23;

import "../Chainlinked.sol";

contract RunLog is Chainlinked {
  bytes32 private externalId;

  function RunLog(address _link, address _oracle) public {
    setLinkToken(_link);
    setOracle(_oracle);
  }

  function request() public {
    ChainlinkLib.Run memory run = newRun("9642f9755366460b922400b79bd202d8", this, "fulfill(bytes32,bytes32)");
    run.add("msg", "hello_chainlink");
    externalId = chainlinkRequest(run, 1 szabo);
  }

  function fulfill(bytes32 _externalId, bytes32 _data)
    public
    onlyOracle
    checkRequestId(_externalId)
  {
  }

  modifier checkRequestId(bytes32 _externalId) {
    require(externalId == _externalId);
    _;
  }
}