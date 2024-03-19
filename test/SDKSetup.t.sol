// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "src/interfaces/IERC7579Account.sol";
import "src/interfaces/IERC7579Module.sol";
import { MockTarget } from "./mocks/MockTarget.sol";
import {
    CallType,
    CALLTYPE_SINGLE,
    CALLTYPE_DELEGATECALL,
    CALLTYPE_STATIC
} from "../src/lib/ModeLib.sol";
import { MockFallback } from "./mocks/MockFallback.sol";
import { MockHook } from "./mocks/MockHook.sol";
import { ExecutionLib } from "src/lib/ExecutionLib.sol";
import {
    ModeLib, ModeCode, CallType, ExecType, ModeSelector, ModePayload
} from "src/lib/ModeLib.sol";
import "./TestBaseUtil.t.sol";
import { Bootstrap } from "src/utils/Bootstrap.sol";

contract SDKSetup is TestBaseUtil {
    address initialValidator;
    address initialExecutor;
    address initialHook;
    address initialFallback;

    Bootstrap _bootstrapSingleton;
    address _factory;

    function setUp() public override {
        super.setUp();

        _bootstrapSingleton = Bootstrap(payable(0x5e9F3feeC2AA6706DF50de955612D964f115523B));
        _factory = 0xFf81C1C2075704D97F6806dE6f733d6dAF20c9c6;

        vm.etch(address(_bootstrapSingleton), address(bootstrapSingleton).code);

        bytes32 salt = bytes32(uint256(0));

        initialValidator = address(new MockValidator{ salt: salt }());
        initialExecutor = address(new MockExecutor{ salt: salt }());
        initialHook = address(new MockHook{ salt: salt }());
        initialFallback = address(new MockFallback{ salt: salt }());
    }

    function getAccountAndInitCodeMock(bytes32 salt)
        internal
        returns (address account, bytes memory initCode)
    {
        // Create config for initial modules
        BootstrapConfig[] memory validators = makeBootstrapConfig(initialValidator, "");
        BootstrapConfig[] memory executors = makeBootstrapConfig(initialExecutor, "");
        BootstrapConfig memory hook = _makeBootstrapConfig(initialHook, "");
        BootstrapConfig[] memory fallbacks = makeBootstrapConfig(initialFallback, "");

        // Create initcode and salt to be sent to Factory
        bytes memory _initCode =
            _bootstrapSingleton._getInitMSACalldata(validators, executors, hook, fallbacks);

        // Get address of new account
        account = factory.getAddress(salt, _initCode);

        // Pack the initcode to include in the userOp
        initCode = abi.encodePacked(
            _factory, abi.encodeWithSelector(factory.createAccount.selector, salt, _initCode)
        );

        // Deal 1 ether to the account
        vm.deal(account, 1 ether);
    }

    function testGetInitCodeUndeployed() public {
        bytes32 salt = keccak256("undeployed");
        (address account, bytes memory initCode) = getAccountAndInitCodeMock(salt);
        console2.log("account", account);
        console2.logBytes(initCode);
    }

    function testGetInitCodeDeployed() public {
        bytes32 salt = keccak256("deployed");
        (address account, bytes memory initCode) = getAccountAndInitCodeMock(salt);
        console2.log("account", account);
        console2.logBytes(initCode);
    }
}
