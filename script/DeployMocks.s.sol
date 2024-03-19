// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Script } from "forge-std/Script.sol";
import { MockValidator } from "test/mocks/MockValidator.sol";
import { MockExecutor } from "test/mocks/MockExecutor.sol";
import { MockHook } from "test/mocks/MockHook.sol";
import { MockFallback } from "test/mocks/MockFallback.sol";

/**
 * @title Deploy
 * @author @kopy-kat
 */
contract DeployScript is Script {
    function run() public {
        bytes32 salt = bytes32(uint256(0));

        vm.startBroadcast(vm.envUint("PK"));

        MockValidator mockValidator = new MockValidator{ salt: salt }();
        MockExecutor mockExecutor = new MockExecutor{ salt: salt }();
        MockHook mockHook = new MockHook{ salt: salt }();
        MockFallback mockFallback = new MockFallback{ salt: salt }();

        vm.stopBroadcast();
    }
}
