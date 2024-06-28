/// @dev SPDX-License-Identifier: MIT
/// @dev Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {OnChainRealEstate} from "./OnChainRealEstate.sol";

contract Manager is Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Error thrown when the fee for real estate registration is invalid
    error Manager__InvalidFeeForRealEstateRegistration();

    /// @dev Error thrown when the fee for agent registration is invalid
    error Manager__InvalidFeeForAgentRegistration();

    /// @dev Error thrown when the agent is invalid
    error Manager__InvalidAgent();

    /// @dev Error thrown when the agent is already registred
    error Manager__AgentAlreadyRegistred();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  CONSTANTS AND IMMUTABLES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The OnChainRealEstate contract instance
    OnChainRealEstate public immutable onChainRealEstateCollection;

    /// @dev The fee for real estate registration
    uint256 public immutable fee;

    /// @dev The fee for agent registration
    uint256 public immutable agentFee;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Event emitted when a new real estate property is registered
    event RealEstateRegistered(address indexed owner, string uri);

    /// @dev Event emitted when a new agent is registered
    event AgentRegistered();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Mapping of agents to their registration status
    mapping(address => bool) private _agents;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          FUNCTIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Constructor
     * @param _initialOwner Owner's address
     * @param _onChainRealEstate Initialize the OnChainRealEstate contract instance
     * @param _fee Set the fee for real estate registration and agent registration
     */
    constructor(address _initialOwner, address _onChainRealEstate, uint256 _fee) Ownable(_initialOwner) {
        fee = _fee;
        agentFee = _fee;
        onChainRealEstateCollection = OnChainRealEstate(_onChainRealEstate);
    }

    /**
     * @dev Function to register a new real estate property.
     * @param _to The 20-byte owner address.
     * @param _uri user-readable string URI for computing `tokenURI`.
     * @notice Check if the caller is a registered
     *         agent & check if the fee is correct.
     */
    function register(address _to, string memory _uri) public payable {
        if (!_agents[msg.sender]) {
            revert Manager__InvalidAgent();
        }
        if (msg.value != fee) {
            revert Manager__InvalidFeeForRealEstateRegistration();
        }
        onChainRealEstateCollection.safeMint(_to, _uri);
        emit RealEstateRegistered(_to, _uri);
    }

    /**
     * @dev Function to register a new agent.
     * @param _agent The 20-byte new agent address.
     */
    function registerAgent(address _agent) public payable {
        if (_agents[_agent]) {
            revert Manager__AgentAlreadyRegistred();
        }
        if (msg.value != agentFee) {
            revert Manager__InvalidFeeForAgentRegistration();
        }
        _agents[_agent] = true;
        emit AgentRegistered();
    }
}
